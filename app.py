import streamlit as st
import pandas as pd
import plotly.express as px
from pathlib import Path

st.set_page_config(page_title="Supply Chain Performance Analytics", page_icon="📦", layout="wide")
DATA_PATH = Path(__file__).parent / "data" / "supply_chain_public.csv.gz"
CHART_FILTERS = {
    "chart_market": "Market", "chart_category": "Category Name",
    "chart_segment": "Customer Segment", "chart_delivery_status": "Delivery Status",
    "chart_customer_status": "Profit Status", "chart_top_customer": "Customer Id",
    "chart_product": "Product Name", "chart_delay_mode": "Shipping Mode",
    "chart_late_mode": "Shipping Mode",
}

@st.cache_data
def load_data(uploaded_file=None):
    data = pd.read_csv(uploaded_file) if uploaded_file is not None else pd.read_csv(DATA_PATH)
    numeric_cols = ["Sales", "Order Profit Per Order", "Days for shipping (real)",
                    "Days for shipment (scheduled)", "Order Item Discount",
                    "Order Item Discount Rate", "Order Item Quantity", "Customer Id"]
    for col in numeric_cols:
        if col in data.columns:
            data[col] = pd.to_numeric(data[col], errors="coerce")
    return data

def get_chart_selection(widget_key):
    state = st.session_state.get(widget_key)
    if state is None:
        return []
    try:
        points = state.get("selection", {}).get("points", [])
    except (AttributeError, TypeError):
        try:
            points = state.selection.points
        except (AttributeError, TypeError):
            points = []
    values = []
    for point in points or []:
        custom = point.get("customdata") if isinstance(point, dict) else None
        if isinstance(custom, (list, tuple)) and custom:
            values.append(custom[0])
        elif custom is not None:
            values.append(custom)
    return list(dict.fromkeys(values))

def render_chart(fig, key):
    st.plotly_chart(fig, use_container_width=True, key=key, on_select="rerun",
                    selection_mode="points")

st.title("📦 Supply Chain Performance Analytics")
st.caption("Interactive analysis of sales, profitability, customers, products and delivery performance. "
           "Select a data point in any chart to cross-filter the dashboard.")

with st.sidebar:
    st.header("Data and filters")
    uploaded = st.file_uploader("Upload a CSV dataset (optional)", type=["csv"])
    data = load_data(uploaded)
    markets = sorted(data["Market"].dropna().astype(str).unique()) if "Market" in data else []
    segments = sorted(data["Customer Segment"].dropna().astype(str).unique()) if "Customer Segment" in data else []
    modes = sorted(data["Shipping Mode"].dropna().astype(str).unique()) if "Shipping Mode" in data else []
    categories = sorted(data["Category Name"].dropna().astype(str).unique()) if "Category Name" in data else []
    selected_markets = st.multiselect("Market", markets, default=markets)
    selected_segments = st.multiselect("Customer segment", segments, default=segments)
    selected_modes = st.multiselect("Shipping mode", modes, default=modes)
    selected_categories = st.multiselect("Category", categories, default=categories)
    st.divider()
    st.subheader("Chart selections")
    if st.button("Clear all chart selections", use_container_width=True):
        for widget_key in CHART_FILTERS:
            st.session_state.pop(widget_key, None)
        st.rerun()

active_chart_filters = {}
for widget_key, column in CHART_FILTERS.items():
    values = get_chart_selection(widget_key)
    if values:
        active_chart_filters[column] = values

filtered = data.copy()
if selected_markets and "Market" in filtered:
    filtered = filtered[filtered["Market"].astype(str).isin(selected_markets)]
if selected_segments and "Customer Segment" in filtered:
    filtered = filtered[filtered["Customer Segment"].astype(str).isin(selected_segments)]
if selected_modes and "Shipping Mode" in filtered:
    filtered = filtered[filtered["Shipping Mode"].astype(str).isin(selected_modes)]
if selected_categories and "Category Name" in filtered:
    filtered = filtered[filtered["Category Name"].astype(str).isin(selected_categories)]
for column, values in active_chart_filters.items():
    if column in filtered.columns:
        filtered = filtered[filtered[column].astype(str).isin([str(v) for v in values])]

if active_chart_filters:
    summary = " | ".join(f"{col}: {', '.join(map(str, vals))}" for col, vals in active_chart_filters.items())
    st.info(f"Active chart filters — {summary}. Use 'Clear all chart selections' in the sidebar to reset.")
if filtered.empty:
    st.warning("No records match the selected filters. Change the filters or clear chart selections.")
    st.stop()

sales = filtered["Sales"].sum()
profit = filtered["Order Profit Per Order"].sum()
margin = profit / sales * 100 if sales else 0
records = len(filtered)
valid_shipments = filtered[filtered["Delivery Status"] != "Shipping canceled"]
late_count = (valid_shipments["Delivery Status"] == "Late delivery").sum()
late_rate = late_count / len(valid_shipments) * 100 if len(valid_shipments) else 0
avg_actual = filtered["Days for shipping (real)"].mean()
avg_scheduled = filtered["Days for shipment (scheduled)"].mean()
avg_delay = avg_actual - avg_scheduled

c1, c2, c3, c4, c5 = st.columns(5)
c1.metric("Total sales", f"{sales:,.2f}")
c2.metric("Total profit", f"{profit:,.2f}")
c3.metric("Profit margin", f"{margin:.2f}%")
c4.metric("Records", f"{records:,}")
c5.metric("Late shipment rate", f"{late_rate:.2f}%")

tab1, tab2, tab3 = st.tabs(["Executive overview", "Customer & product", "Delivery operations"])
with tab1:
    left, right = st.columns(2)
    with left:
        market_summary = filtered.groupby("Market", as_index=False).agg(Sales=("Sales", "sum"))
        fig = px.bar(market_summary.sort_values("Sales", ascending=False), x="Market", y="Sales",
                     title="Sales by market", text_auto=".2s", custom_data=["Market"])
        render_chart(fig, "chart_market")
    with right:
        category_summary = filtered.groupby("Category Name", as_index=False).agg(
            Profit=("Order Profit Per Order", "sum")).sort_values("Profit", ascending=False).head(12)
        fig = px.bar(category_summary, x="Profit", y="Category Name", orientation="h",
                     title="Top categories by profit", custom_data=["Category Name"])
        render_chart(fig, "chart_category")
    left, right = st.columns(2)
    with left:
        segment_summary = filtered.groupby("Customer Segment", as_index=False).agg(
            Sales=("Sales", "sum"), Profit=("Order Profit Per Order", "sum"))
        fig = px.bar(segment_summary, x="Customer Segment", y=["Sales", "Profit"], barmode="group",
                     title="Sales and profit by customer segment", custom_data=["Customer Segment"])
        render_chart(fig, "chart_segment")
    with right:
        ship_summary = filtered["Delivery Status"].value_counts().rename_axis(
            "Delivery Status").reset_index(name="Records")
        fig = px.pie(ship_summary, names="Delivery Status", values="Records",
                     title="Delivery status distribution", hole=0.45, custom_data=["Delivery Status"])
        render_chart(fig, "chart_delivery_status")

with tab2:
    if "Customer Id" in filtered.columns:
        customer = filtered.groupby("Customer Id", as_index=False).agg(
            Orders=("Customer Id", "size"), Sales=("Sales", "sum"),
            Profit=("Order Profit Per Order", "sum"))
        customer["Profit Margin"] = customer["Profit"].div(
            customer["Sales"].where(customer["Sales"] != 0)).mul(100)
        customer["Profit Status"] = customer["Profit"].apply(
            lambda x: "Profitable" if x > 0 else ("Loss-making" if x < 0 else "Break-even"))
        status = customer["Profit Status"].value_counts().rename_axis(
            "Profit Status").reset_index(name="Customers")
        left, right = st.columns(2)
        with left:
            fig = px.pie(status, names="Profit Status", values="Customers",
                         title="Customer profitability distribution", hole=0.4,
                         custom_data=["Profit Status"])
            render_chart(fig, "chart_customer_status")
        with right:
            top_customers = customer.sort_values("Profit", ascending=False).head(10)
            fig = px.bar(top_customers, x="Profit", y="Customer Id", orientation="h",
                         title="Top 10 customers by profit", custom_data=["Customer Id"])
            render_chart(fig, "chart_top_customer")
        st.subheader("Customers with the lowest profit")
        st.dataframe(customer.sort_values("Profit").head(10), use_container_width=True, hide_index=True)

    product = filtered.groupby("Product Name", as_index=False).agg(
        Orders=("Product Name", "size"), Sales=("Sales", "sum"),
        Profit=("Order Profit Per Order", "sum")).sort_values("Profit", ascending=False)
    st.subheader("Product profitability")
    fig = px.bar(product.head(10).sort_values("Profit"), x="Profit", y="Product Name",
                 orientation="h", title="Top 10 products by profit", custom_data=["Product Name"])
    render_chart(fig, "chart_product")
    st.dataframe(product.head(10), use_container_width=True, hide_index=True)

with tab3:
    delay = filtered.copy()
    delay["Shipping Delay Days"] = delay["Days for shipping (real)"] - delay["Days for shipment (scheduled)"]
    left, right = st.columns(2)
    with left:
        mode_summary = delay.groupby("Shipping Mode", as_index=False).agg(
            Average_Delay=("Shipping Delay Days", "mean"))
        fig = px.bar(mode_summary.sort_values("Average_Delay", ascending=False),
                     x="Shipping Mode", y="Average_Delay",
                     title="Average shipping delay by shipping mode", custom_data=["Shipping Mode"])
        render_chart(fig, "chart_delay_mode")
    with right:
        valid = delay[delay["Delivery Status"] != "Shipping canceled"]
        mode_late = valid.assign(Is_Late=valid["Delivery Status"].eq("Late delivery")).groupby(
            "Shipping Mode", as_index=False).agg(
                Late_Shipments=("Is_Late", "sum"), Valid_Shipments=("Is_Late", "size"))
        mode_late["Late Rate (%)"] = mode_late["Late_Shipments"] / mode_late["Valid_Shipments"] * 100
        fig = px.bar(mode_late.sort_values("Late Rate (%)", ascending=False),
                     x="Shipping Mode", y="Late Rate (%)",
                     title="Late shipment rate by shipping mode", text_auto=".1f",
                     custom_data=["Shipping Mode"])
        render_chart(fig, "chart_late_mode")
    st.metric("Average shipping delay (actual minus scheduled)", f"{avg_delay:.2f} days")
    status_table = filtered["Delivery Status"].value_counts().rename_axis(
        "Delivery Status").reset_index(name="Records")
    st.dataframe(status_table, use_container_width=True, hide_index=True)

st.divider()
st.caption(
    "Data note: this dashboard uses the CSV supplied for the Unified Mentor internship project. "
    "The source CSV contains 180,519 rows. Earlier SQL analysis in the project used 180,516 rows; "
    "the three-record difference has not been reconciled. Figures may therefore differ between this "
    "application and the SQL-based Power BI dashboard. Customer names, street addresses, ZIP codes "
    "and precise coordinates have been excluded from the public app dataset."
)
