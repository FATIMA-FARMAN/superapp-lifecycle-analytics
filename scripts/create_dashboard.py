import duckdb
import plotly.graph_objects as go
from plotly.subplots import make_subplots

print("📊 Generating SuperApp Analytics Dashboard...")

conn = duckdb.connect('dev.duckdb')

# Get data
gmv_trend = conn.execute("""
    SELECT 
        DATE_TRUNC('month', transaction_date) as month,
        product,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as gmv
    FROM main_marts.fct_transactions
    GROUP BY 1, 2
    ORDER BY 1, 2
""").fetchdf()

activation = conn.execute("""
    SELECT 
        products_used,
        COUNT(*) as user_count
    FROM main_marts.dim_users
    GROUP BY 1
    ORDER BY 1
""").fetchdf()

activation['label'] = activation['products_used'].astype(str) + ' Product' + activation['products_used'].apply(lambda x: 's' if x != 1 else '')

geo_performance = conn.execute("""
    SELECT 
        country,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as gmv
    FROM main_marts.fct_transactions
    GROUP BY 1
    ORDER BY gmv DESC
    LIMIT 5
""").fetchdf()

metrics = conn.execute("""
    SELECT 
        COUNT(DISTINCT user_id) as users,
        COUNT(*) as transactions,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as gmv
    FROM main_marts.fct_transactions
""").fetchdf()

# Create dashboard with proper spacing
dashboard = make_subplots(
    rows=3, cols=2,
    specs=[
        [{"type": "indicator"}, {"type": "indicator"}],
        [{"type": "scatter"}, {"type": "funnel"}],
        [{"type": "bar", "colspan": 2}, None]
    ],
    row_heights=[0.20, 0.45, 0.35],
    vertical_spacing=0.12,
    horizontal_spacing=0.15,
    subplot_titles=('', '', 'GMV Trend by Product', 'Product Adoption Funnel', 'Top 5 Countries by GMV', '')
)

# Row 1: Two separate indicators (no overlap)
dashboard.add_trace(go.Indicator(
    mode="number",
    value=metrics['gmv'][0],
    number={'prefix': "$", 'valueformat': ",.0f", 'font': {'size': 48}},
    title={'text': "Total GMV", 'font': {'size': 18}}
), row=1, col=1)

dashboard.add_trace(go.Indicator(
    mode="number+delta",
    value=metrics['users'][0],
    number={'valueformat': ",", 'font': {'size': 40}},
    title={'text': f"{metrics['transactions'][0]:,} Transactions", 'font': {'size': 14}},
    delta={'reference': 45000, 'relative': False}
), row=1, col=2)

# Row 2: GMV Trend
colors = {'bnpl': '#1f77b4', 'food_delivery': '#ff7f0e', 'ride_sharing': '#2ca02c', 'gaming': '#d62728'}
for product in gmv_trend['product'].unique():
    df = gmv_trend[gmv_trend['product'] == product]
    dashboard.add_trace(
        go.Scatter(
            x=df['month'], 
            y=df['gmv'], 
            name=product.replace('_', ' ').title(),
            mode='lines+markers',
            line=dict(width=2, color=colors.get(product))
        ),
        row=2, col=1
    )

# Row 2: Funnel
dashboard.add_trace(
    go.Funnel(
        y=activation['label'],
        x=activation['user_count'],
        textinfo="value+percent initial",
        marker=dict(color=["#636EFA", "#EF553B", "#00CC96", "#AB63FA", "#FFA15A"])
    ),
    row=2, col=2
)

# Row 3: Geographic bars
dashboard.add_trace(
    go.Bar(
        x=geo_performance['country'], 
        y=geo_performance['gmv'],
        text=geo_performance['gmv'].apply(lambda x: f'${x/1e6:.1f}M'),
        textposition='outside',
        marker_color='#1f77b4',
        showlegend=False
    ),
    row=3, col=1
)

# Update layout
dashboard.update_layout(
    title={
        'text': "SuperApp Lifecycle Analytics Dashboard",
        'font': {'size': 24},
        'x': 0.5,
        'xanchor': 'center',
        'y': 0.98
    },
    height=1200,
    showlegend=True,
    legend=dict(x=0.02, y=0.6, font=dict(size=11)),
    font=dict(family="Arial", size=11),
    plot_bgcolor='#f8f9fa',
    paper_bgcolor='white'
)

dashboard.update_xaxes(title_text="Month", row=2, col=1)
dashboard.update_yaxes(title_text="GMV ($)", row=2, col=1)
dashboard.update_xaxes(title_text="Country", row=3, col=1)
dashboard.update_yaxes(title_text="GMV ($)", row=3, col=1)

dashboard.write_html('docs/dashboard.html')
print("✅ Dashboard saved!")

conn.close()
