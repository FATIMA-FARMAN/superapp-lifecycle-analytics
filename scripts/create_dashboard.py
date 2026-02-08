import duckdb
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import plotly.express as px
from datetime import datetime

print("📊 Generating SuperApp Analytics Dashboard...")

# Connect to DuckDB
conn = duckdb.connect('dev.duckdb')

# 1. GMV by Product Over Time
print("📈 Chart 1: GMV Trend by Product...")
gmv_trend = conn.execute("""
    SELECT 
        DATE_TRUNC('month', transaction_date) as month,
        product,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as gmv
    FROM main_marts.fct_transactions
    GROUP BY 1, 2
    ORDER BY 1, 2
""").fetchdf()

fig1 = px.line(gmv_trend, x='month', y='gmv', color='product',
               title='GMV Trend by Product (Monthly)',
               labels={'gmv': 'GMV ($)', 'month': 'Month', 'product': 'Product'},
               color_discrete_map={
                   'bnpl': '#1f77b4',
                   'food_delivery': '#ff7f0e', 
                   'ride_sharing': '#2ca02c',
                   'gaming': '#d62728'
               })
fig1.update_layout(height=400, hovermode='x unified')

# 2. User Activation Funnel
print("🎯 Chart 2: Activation Funnel...")
activation = conn.execute("""
    SELECT 
        products_used,
        COUNT(*) as user_count
    FROM main_marts.dim_users
    GROUP BY 1
    ORDER BY 1
""").fetchdf()

activation['products_used_label'] = activation['products_used'].astype(str) + ' Product' + activation['products_used'].apply(lambda x: 's' if x != 1 else '')

fig2 = go.Figure(go.Funnel(
    y = activation['products_used_label'],
    x = activation['user_count'],
    textinfo = "value+percent initial",
    marker = {"color": ["#636EFA", "#EF553B", "#00CC96", "#AB63FA", "#FFA15A"]}
))
fig2.update_layout(title='User Product Adoption Funnel', height=400)

# 3. Geographic Performance
print("🌍 Chart 3: Geographic Performance...")
geo_performance = conn.execute("""
    SELECT 
        country,
        COUNT(DISTINCT user_id) as users,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as gmv,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) / 
            COUNT(DISTINCT user_id) as gmv_per_user
    FROM main_marts.fct_transactions
    GROUP BY 1
    ORDER BY gmv DESC
    LIMIT 10
""").fetchdf()

fig3 = make_subplots(
    rows=1, cols=2,
    subplot_titles=('Total GMV by Country', 'GMV per User by Country'),
    specs=[[{"type": "bar"}, {"type": "bar"}]]
)

fig3.add_trace(
    go.Bar(x=geo_performance['country'], y=geo_performance['gmv'], 
           name='Total GMV', marker_color='#1f77b4'),
    row=1, col=1
)

fig3.add_trace(
    go.Bar(x=geo_performance['country'], y=geo_performance['gmv_per_user'],
           name='GMV per User', marker_color='#ff7f0e'),
    row=1, col=2
)

fig3.update_layout(height=400, showlegend=False)
fig3.update_xaxes(tickangle=-45)

# 4. Product Mix Analysis
print("🎨 Chart 4: Product Revenue Mix...")
product_mix = conn.execute("""
    SELECT 
        product,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as gmv,
        COUNT(*) as transactions
    FROM main_marts.fct_transactions
    GROUP BY 1
    ORDER BY gmv DESC
""").fetchdf()

fig4 = make_subplots(
    rows=1, cols=2,
    specs=[[{"type": "pie"}, {"type": "pie"}]],
    subplot_titles=('GMV Distribution', 'Transaction Distribution')
)

fig4.add_trace(
    go.Pie(labels=product_mix['product'], values=product_mix['gmv'], 
           name='GMV', hole=0.3),
    row=1, col=1
)

fig4.add_trace(
    go.Pie(labels=product_mix['product'], values=product_mix['transactions'],
           name='Transactions', hole=0.3),
    row=1, col=2
)

fig4.update_layout(height=400)

# 5. Key Metrics Summary
print("📊 Chart 5: Key Metrics...")
metrics = conn.execute("""
    SELECT 
        COUNT(DISTINCT user_id) as total_users,
        COUNT(*) as total_transactions,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as total_gmv,
        AVG(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as avg_order_value
    FROM main_marts.fct_transactions
""").fetchdf()

fig5 = go.Figure()
fig5.add_trace(go.Indicator(
    mode = "number",
    value = metrics['total_users'][0],
    title = {"text": "Total Users"},
    domain = {'x': [0, 0.25], 'y': [0.5, 1]}
))
fig5.add_trace(go.Indicator(
    mode = "number",
    value = metrics['total_transactions'][0],
    title = {"text": "Total Transactions"},
    domain = {'x': [0.25, 0.5], 'y': [0.5, 1]}
))
fig5.add_trace(go.Indicator(
    mode = "number",
    value = metrics['total_gmv'][0],
    number = {'prefix': "$", 'valueformat': ",.0f"},
    title = {"text": "Total GMV"},
    domain = {'x': [0.5, 0.75], 'y': [0.5, 1]}
))
fig5.add_trace(go.Indicator(
    mode = "number",
    value = metrics['avg_order_value'][0],
    number = {'prefix': "$", 'valueformat': ".2f"},
    title = {"text": "Avg Order Value"},
    domain = {'x': [0.75, 1], 'y': [0.5, 1]}
))
fig5.update_layout(height=300)

# Combine into single HTML dashboard
print("🎨 Creating combined dashboard...")
from plotly.subplots import make_subplots

dashboard = make_subplots(
    rows=3, cols=2,
    subplot_titles=('Key Metrics', 'GMV Trend by Product',
                    'Product Adoption Funnel', 'Geographic Performance',
                    'Revenue Mix', 'Transaction Mix'),
    specs=[[{"type": "indicator", "colspan": 2}, None],
           [{"type": "scatter"}, {"type": "funnel"}],
           [{"type": "bar", "colspan": 2}, None]],
    row_heights=[0.2, 0.4, 0.4],
    vertical_spacing=0.12,
    horizontal_spacing=0.1
)

# Add metrics (simplified for subplot)
dashboard.add_trace(go.Indicator(
    mode="number+delta",
    value=metrics['total_gmv'][0],
    number={'prefix': "$", 'valueformat': ",.0f"},
    title={"text": f"Total GMV<br><sub>{metrics['total_transactions'][0]:,} transactions from {metrics['total_users'][0]:,} users</sub>"}
), row=1, col=1)

# Add GMV trend
for product in gmv_trend['product'].unique():
    df_product = gmv_trend[gmv_trend['product'] == product]
    dashboard.add_trace(
        go.Scatter(x=df_product['month'], y=df_product['gmv'], 
                   name=product, mode='lines+markers'),
        row=2, col=1
    )

# Add funnel
dashboard.add_trace(
    go.Funnel(
        y=activation['products_used_label'],
        x=activation['user_count'],
        textinfo="value+percent initial"
    ),
    row=2, col=2
)

# Add geographic bars
dashboard.add_trace(
    go.Bar(x=geo_performance['country'][:5], 
           y=geo_performance['gmv'][:5],
           name='GMV by Country',
           marker_color='#1f77b4'),
    row=3, col=1
)

dashboard.update_layout(
    title_text="SuperApp Lifecycle Analytics Dashboard",
    title_font_size=24,
    height=1200,
    showlegend=True
)

dashboard.update_xaxes(title_text="Month", row=2, col=1)
dashboard.update_yaxes(title_text="GMV ($)", row=2, col=1)
dashboard.update_xaxes(title_text="Country", row=3, col=1, tickangle=-45)
dashboard.update_yaxes(title_text="GMV ($)", row=3, col=1)

# Save dashboard
dashboard.write_html('docs/dashboard.html')
print("✅ Dashboard saved to docs/dashboard.html")

# Save individual charts too
fig1.write_html('docs/chart_gmv_trend.html')
fig2.write_html('docs/chart_funnel.html')
fig3.write_html('docs/chart_geographic.html')
fig4.write_html('docs/chart_product_mix.html')

conn.close()

print("\n🎉 Dashboard generation complete!")
print("📁 Files created:")
print("   • docs/dashboard.html (main dashboard)")
print("   • docs/chart_*.html (individual charts)")
