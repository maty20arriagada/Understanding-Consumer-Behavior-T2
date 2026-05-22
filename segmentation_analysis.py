import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
import plotly.express as px
import plotly.graph_objects as go
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import os
import warnings

warnings.filterwarnings('ignore')

def main():
    print("="*60)
    print("INICIANDO SEGMENTACIÓN DE CLIENTES (ELECTRÓNICA)")
    print("="*60)

    # 1. Cargar datos
    print("[1/5] Cargando y fusionando datos...")
    orders = pd.read_csv('orders.csv')
    customers = pd.read_csv('customers.csv')
    
    # Fusionar
    df = pd.merge(orders, customers, on='customer_id', how='inner')
    
    # 2. Filtrar por Electrónica y órdenes finalizadas
    print("[2/5] Filtrando segmento: Electrónica y órdenes válidas...")
    df_elec = df[(df['category'] == 'Electronics') & 
                 (df['order_status'].isin(['Delivered', 'Returned']))]
    
    print(f"Total transacciones de electrónica válidas: {len(df_elec)}")
    print(f"Total clientes únicos en este segmento: {df_elec['customer_id'].nunique()}")

    if df_elec.empty:
        print("ERROR: No hay datos después del filtro.")
        return

    # Convertir fecha a datetime
    df_elec['order_date'] = pd.to_datetime(df_elec['order_date'])
    reference_date = df_elec['order_date'].max() + pd.Timedelta(days=1)

    # =====================================================================
    # SEGMENTACIÓN 1: RFM (Recency, Frequency, Monetary)
    # =====================================================================
    print("\n[3/5] Procesando Segmentación RFM...")
    rfm = df_elec.groupby('customer_id').agg({
        'order_date': lambda x: (reference_date - x.max()).days,
        'order_id': 'count',
        'total_amount_usd': 'sum'
    }).reset_index()
    
    rfm.columns = ['customer_id', 'Recency', 'Frequency', 'Monetary']
    
    # Escalar datos
    scaler_rfm = StandardScaler()
    rfm_scaled = scaler_rfm.fit_transform(rfm[['Recency', 'Frequency', 'Monetary']])
    
    # --- MÉTODO DEL CODO (Elbow Method) para RFM ---
    print("   -> Generando gráfico del Método del Codo para RFM...")
    inertia_rfm = []
    K_range = range(1, 11)
    for k in K_range:
        km = KMeans(n_clusters=k, random_state=42, n_init=10)
        km.fit(rfm_scaled)
        inertia_rfm.append(km.inertia_)
        
    plt.figure(figsize=(8, 5))
    plt.plot(K_range, inertia_rfm, marker='o', linestyle='--', color='b')
    plt.title('Método del Codo - Segmentación RFM')
    plt.xlabel('Número de Clusters (k)')
    plt.ylabel('Inercia (Suma de distancias al cuadrado)')
    plt.grid(True)
    os.makedirs('output_plots', exist_ok=True)
    plt.savefig('output_plots/elbow_method_rfm.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # Aplicar K-Means (Elegimos 4 clusters como base estratégica, validado por el codo)
    kmeans_rfm = KMeans(n_clusters=4, random_state=42, n_init=10)
    rfm['Cluster'] = kmeans_rfm.fit_predict(rfm_scaled)
    
    # Mapeo simple: el cluster con más Monetary es "Campeones", etc.
    # Para ser robustos, solo usaremos identificadores de cluster como strings
    # Mapeo simple: el cluster con más Monetary es "Campeones", etc.
    # Para ser robustos, solo usaremos identificadores de cluster como strings
    rfm['Cluster_Name'] = 'Cluster ' + rfm['Cluster'].astype(str)
    
    # Graficar RFM 3D con Plotly
    fig_rfm = px.scatter_3d(
        rfm, x='Recency', y='Frequency', z='Monetary',
        color='Cluster_Name',
        title='Segmentación RFM 3D - Mercado de Electrónica',
        labels={'Recency': 'Recency (Días)', 'Frequency': 'Frequency (Compras)', 'Monetary': 'Monetary (USD)'},
        color_discrete_sequence=px.colors.qualitative.Set1,
        hover_data=['customer_id']
    )
    
    fig_rfm.update_layout(scene=dict(
        xaxis_title='Recency (Menor es mejor)',
        yaxis_title='Frequency',
        zaxis_title='Monetary (USD)'
    ), margin=dict(l=0, r=0, b=0, t=40))
    
    os.makedirs('output_plots', exist_ok=True)
    fig_rfm.write_html('output_plots/rfm_3d_clusters.html')
    print(" -> Gráfico RFM (Plotly) exportado a 'output_plots/rfm_3d_clusters.html'")

    # Graficar RFM 3D con Matplotlib
    fig_plt_rfm = plt.figure(figsize=(10, 8))
    ax_rfm = fig_plt_rfm.add_subplot(111, projection='3d')
    scatter_rfm = ax_rfm.scatter(rfm['Recency'], rfm['Frequency'], rfm['Monetary'], 
                                 c=rfm['Cluster'], cmap='Set1', s=40, alpha=0.7)
    ax_rfm.set_xlabel('Recency (Días)')
    ax_rfm.set_ylabel('Frequency (Compras)')
    ax_rfm.set_zlabel('Monetary (USD)')
    ax_rfm.set_title('Segmentación RFM 3D - Mercado de Electrónica (Matplotlib)')
    fig_plt_rfm.colorbar(scatter_rfm, label='Cluster')
    plt.savefig('output_plots/rfm_3d_clusters_matplotlib.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(" -> Gráfico RFM (Matplotlib) exportado a 'output_plots/rfm_3d_clusters_matplotlib.png'")

    # =====================================================================
    # SEGMENTACIÓN 2: SOCIODEMOGRÁFICA Y CONDUCTUAL
    # =====================================================================
    print("\n[4/5] Procesando Segmentación Sociodemográfica y Conductual...")
    
    # Extraer atributos por cliente
    socio = df_elec.groupby('customer_id').agg({
        'age': 'first',
        'gender': 'first',
        'membership_tier': 'first',
        'session_duration_minutes': 'mean',
        'pages_viewed_before_purchase': 'mean',
        'returns_made': 'first' # asumiendo que es prop del cliente
    }).reset_index()
    
    # Preprocesamiento (Codificación)
    # Genero: M=0, F=1, etc.
    le_gender = LabelEncoder()
    socio['gender_encoded'] = le_gender.fit_transform(socio['gender'].fillna('Unknown'))
    
    # Membresía: Ordinal (Free=0, Silver=1, Gold=2, Platinum=3)
    tier_map = {'Free': 0, 'Silver': 1, 'Gold': 2, 'Platinum': 3}
    socio['membership_encoded'] = socio['membership_tier'].map(tier_map).fillna(0)
    
    # Variables a usar en el cluster
    features = ['age', 'gender_encoded', 'membership_encoded', 
                'session_duration_minutes', 'pages_viewed_before_purchase', 'returns_made']
    
    socio_clean = socio.dropna(subset=features)
    
    # Escalar
    scaler_socio = StandardScaler()
    socio_scaled = scaler_socio.fit_transform(socio_clean[features])
    
    # --- MÉTODO DEL CODO (Elbow Method) para Socio-demográfico ---
    print("   -> Generando gráfico del Método del Codo para Socio-demográfico...")
    inertia_socio = []
    for k in K_range:
        km = KMeans(n_clusters=k, random_state=42, n_init=10)
        km.fit(socio_scaled)
        inertia_socio.append(km.inertia_)
        
    plt.figure(figsize=(8, 5))
    plt.plot(K_range, inertia_socio, marker='o', linestyle='--', color='g')
    plt.title('Método del Codo - Segmentación Sociodemográfica')
    plt.xlabel('Número de Clusters (k)')
    plt.ylabel('Inercia (Suma de distancias al cuadrado)')
    plt.grid(True)
    plt.savefig('output_plots/elbow_method_socio.png', dpi=300, bbox_inches='tight')
    plt.close()

    # PCA para reducir a 3 dimensiones visualizables y extraer componentes principales
    pca = PCA(n_components=3, random_state=42)
    socio_pca = pca.fit_transform(socio_scaled)
    
    socio_clean['PCA_1'] = socio_pca[:, 0]
    socio_clean['PCA_2'] = socio_pca[:, 1]
    socio_clean['PCA_3'] = socio_pca[:, 2]
    
    # Aplicar K-Means (4 clusters)
    kmeans_socio = KMeans(n_clusters=4, random_state=42, n_init=10)
    socio_clean['Cluster'] = kmeans_socio.fit_predict(socio_scaled)
    socio_clean['Cluster_Name'] = 'Perfil ' + socio_clean['Cluster'].astype(str)
    
    # Nombres descriptivos de los ejes PCA para que el gráfico sea autoexplicativo
    pca_labels = {
        'PCA_1': 'Jóvenes c/Sesión Larga vs Adultos c/Membresía (PCA 1)',
        'PCA_2': 'Género y Propensión a Devoluciones (PCA 2)',
        'PCA_3': 'Alta Exploración de Páginas (PCA 3)'
    }

    # Graficar 3D PCA con Plotly
    fig_socio = px.scatter_3d(
        socio_clean, x='PCA_1', y='PCA_2', z='PCA_3',
        color='Cluster_Name',
        title='Segmentación Sociodemográfica & Conductual 3D (PCA)',
        labels=pca_labels,
        color_discrete_sequence=px.colors.qualitative.Pastel,
        hover_data=['age', 'gender', 'membership_tier', 'session_duration_minutes']
    )
    
    fig_socio.update_layout(margin=dict(l=0, r=0, b=0, t=40))
    fig_socio.write_html('output_plots/socio_behavioral_3d_clusters.html')
    print(" -> Gráfico Sociodemográfico (Plotly) exportado a 'output_plots/socio_behavioral_3d_clusters.html'")

    # Extraer e interpretar los pesos de los componentes principales (Loadings)
    pca_loadings = pd.DataFrame(pca.components_.T, columns=['PCA_1', 'PCA_2', 'PCA_3'], index=features)
    
    # Graficar 3D PCA con Matplotlib
    fig_plt_socio = plt.figure(figsize=(12, 9))
    ax_socio = fig_plt_socio.add_subplot(111, projection='3d')
    scatter_socio = ax_socio.scatter(socio_clean['PCA_1'], socio_clean['PCA_2'], socio_clean['PCA_3'], 
                                     c=socio_clean['Cluster'], cmap='tab10', s=40, alpha=0.7)
    ax_socio.set_xlabel('Edad/Sesión (PCA 1)', labelpad=10)
    ax_socio.set_ylabel('Género/Devoluciones (PCA 2)', labelpad=10)
    ax_socio.set_zlabel('Exploración/Páginas (PCA 3)', labelpad=10)
    ax_socio.set_title('Segmentación Sociodemográfica & Conductual 3D (Matplotlib)')
    fig_plt_socio.colorbar(scatter_socio, label='Cluster')
    plt.savefig('output_plots/socio_behavioral_3d_clusters_matplotlib.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(" -> Gráfico Sociodemográfico (Matplotlib) exportado a 'output_plots/socio_behavioral_3d_clusters_matplotlib.png'")

    # =====================================================================
    # EXPORTAR RESULTADOS (Resumen)
    # =====================================================================
    print("\n[5/5] Exportando resúmenes estadísticos...")
    os.makedirs('output_tables', exist_ok=True)
    
    rfm_summary = rfm.groupby('Cluster_Name')[['Recency', 'Frequency', 'Monetary']].mean().round(2)
    rfm_summary['Count'] = rfm.groupby('Cluster_Name').size()
    rfm_summary.to_csv('output_tables/rfm_clusters_summary.csv')
    
    socio_summary = socio_clean.groupby('Cluster_Name')[['age', 'session_duration_minutes', 'pages_viewed_before_purchase']].mean().round(2)
    socio_summary['Count'] = socio_clean.groupby('Cluster_Name').size()
    socio_summary.to_csv('output_tables/socio_clusters_summary.csv')
    
    # Guardar PCA loadings
    pca_loadings.to_csv('output_tables/pca_components_loadings.csv')
    
    print("Resúmenes guardados en 'output_tables/'.")
    print("="*60)
    print("ANÁLISIS COMPLETADO CON ÉXITO")
    print("="*60)

if __name__ == "__main__":
    main()
