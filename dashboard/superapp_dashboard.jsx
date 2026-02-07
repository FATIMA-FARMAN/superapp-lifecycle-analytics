import { useState } from "react";
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from "recharts";

// Data based on actual project metrics (500 users, 5738 txns, $800K GMV)
const kpiData = {
  totalGMV: 800590,
  totalUsers: 500,
  totalTransactions: 5738,
  totalEvents: 13314,
  completionRate: 78,
  avgGMVPerUser: 1601.18,
  products: 4,
  markets: 4
};

const gmvByProduct = [
  { product: "BNPL", gmv: 488360, txns: 2008, color: "#E8B931", pct: 61.0 },
  { product: "Food Delivery", gmv: 185070, txns: 1721, color: "#4ECDC4", pct: 23.1 },
  { product: "Ride Sharing", gmv: 78650, txns: 1148, color: "#FF6B6B", pct: 9.8 },
  { product: "Gaming", gmv: 48510, txns: 861, color: "#A78BFA", pct: 6.1 }
];

const usersByCountry = [
  { country: "UAE", users: 175, pct: 35 },
  { country: "Saudi Arabia", users: 150, pct: 30 },
  { country: "Egypt", users: 100, pct: 20 },
  { country: "Kuwait", users: 75, pct: 15 }
];

const monthlyGMV = [
  { month: "Jan 24", gmv: 42500, txns: 310, users: 45 },
  { month: "Feb 24", gmv: 48200, txns: 355, users: 52 },
  { month: "Mar 24", gmv: 55800, txns: 398, users: 58 },
  { month: "Apr 24", gmv: 61200, txns: 432, users: 62 },
  { month: "May 24", gmv: 58900, txns: 418, users: 55 },
  { month: "Jun 24", gmv: 63400, txns: 448, users: 68 },
  { month: "Jul 24", gmv: 68100, txns: 472, users: 72 },
  { month: "Aug 24", gmv: 72300, txns: 498, users: 78 },
  { month: "Sep 24", gmv: 69800, txns: 465, users: 70 },
  { month: "Oct 24", gmv: 75400, txns: 512, users: 82 },
  { month: "Nov 24", gmv: 82100, txns: 548, users: 88 },
  { month: "Dec 24", gmv: 68500, txns: 462, users: 75 },
  { month: "Jan 25", gmv: 34290, txns: 420, users: 60 }
];

const retentionCohorts = [
  { cohort: "Jan 24", m0: 100, m1: 72, m2: 58, m3: 48, m4: 41, m5: 35, m6: 30 },
  { cohort: "Feb 24", m0: 100, m1: 69, m2: 55, m3: 46, m4: 39, m5: 33, m6: null },
  { cohort: "Mar 24", m0: 100, m1: 74, m2: 61, m3: 50, m4: 42, m5: null, m6: null },
  { cohort: "Apr 24", m0: 100, m1: 71, m2: 57, m3: 47, m4: null, m5: null, m6: null },
  { cohort: "May 24", m0: 100, m1: 68, m2: 54, m3: null, m4: null, m5: null, m6: null },
  { cohort: "Jun 24", m0: 100, m1: 73, m2: null, m3: null, m4: null, m5: null, m6: null }
];

const segmentBreakdown = [
  { segment: "New", users: 200, avgGMV: 420, color: "#4ECDC4" },
  { segment: "Regular", users: 200, avgGMV: 1580, color: "#E8B931" },
  { segment: "VIP", users: 100, avgGMV: 4250, color: "#FF6B6B" }
];

const activationData = [
  { day: "Day 0", pct: 12 },
  { day: "Day 1", pct: 28 },
  { day: "Day 3", pct: 45 },
  { day: "Day 7", pct: 62 },
  { day: "Day 14", pct: 74 },
  { day: "Day 30", pct: 82 },
  { day: "Day 60", pct: 88 },
  { day: "Day 90", pct: 91 }
];

const statusBreakdown = [
  { name: "Completed", value: 78, color: "#4ECDC4" },
  { name: "Failed", value: 15, color: "#FF6B6B" },
  { name: "Pending", value: 7, color: "#E8B931" }
];

const formatCurrency = (val) => {
  if (val >= 1000000) return `$${(val / 1000000).toFixed(1)}M`;
  if (val >= 1000) return `$${(val / 1000).toFixed(0)}K`;
  return `$${val}`;
};

const formatNumber = (val) => {
  if (val >= 1000) return `${(val / 1000).toFixed(1)}K`;
  return val;
};

const KPICard = ({ label, value, sub, accent }) => (
  <div style={{
    background: "rgba(255,255,255,0.03)",
    border: "1px solid rgba(255,255,255,0.06)",
    borderRadius: 16,
    padding: "24px 20px",
    position: "relative",
    overflow: "hidden",
    transition: "all 0.3s ease",
  }}
    onMouseEnter={e => {
      e.currentTarget.style.background = "rgba(255,255,255,0.06)";
      e.currentTarget.style.borderColor = accent || "#E8B931";
      e.currentTarget.style.transform = "translateY(-2px)";
    }}
    onMouseLeave={e => {
      e.currentTarget.style.background = "rgba(255,255,255,0.03)";
      e.currentTarget.style.borderColor = "rgba(255,255,255,0.06)";
      e.currentTarget.style.transform = "translateY(0)";
    }}
  >
    <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 2, background: accent || "#E8B931", opacity: 0.6 }} />
    <p style={{ fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: "uppercase", color: "rgba(255,255,255,0.4)", margin: "0 0 12px 0", fontFamily: "'DM Sans', sans-serif" }}>{label}</p>
    <p style={{ fontSize: 32, fontWeight: 700, color: "#fff", margin: "0 0 4px 0", fontFamily: "'Space Mono', monospace", lineHeight: 1 }}>{value}</p>
    {sub && <p style={{ fontSize: 12, color: accent || "rgba(255,255,255,0.35)", margin: 0, fontFamily: "'DM Sans', sans-serif" }}>{sub}</p>}
  </div>
);

const SectionTitle = ({ children, subtitle }) => (
  <div style={{ marginBottom: 20 }}>
    <h2 style={{ fontSize: 18, fontWeight: 600, color: "#fff", margin: 0, fontFamily: "'DM Sans', sans-serif", letterSpacing: -0.3 }}>{children}</h2>
    {subtitle && <p style={{ fontSize: 12, color: "rgba(255,255,255,0.35)", margin: "4px 0 0 0", fontFamily: "'DM Sans', sans-serif" }}>{subtitle}</p>}
  </div>
);

const ChartCard = ({ children, style }) => (
  <div style={{
    background: "rgba(255,255,255,0.02)",
    border: "1px solid rgba(255,255,255,0.06)",
    borderRadius: 16,
    padding: 24,
    ...style
  }}>
    {children}
  </div>
);

const RetentionHeatmap = ({ data }) => {
  const months = ["M0", "M1", "M2", "M3", "M4", "M5", "M6"];
  const getColor = (val) => {
    if (val === null || val === undefined) return "rgba(255,255,255,0.02)";
    if (val >= 70) return "rgba(78, 205, 196, 0.7)";
    if (val >= 50) return "rgba(78, 205, 196, 0.45)";
    if (val >= 35) return "rgba(232, 185, 49, 0.45)";
    return "rgba(255, 107, 107, 0.35)";
  };

  return (
    <div style={{ overflowX: "auto" }}>
      <div style={{ display: "grid", gridTemplateColumns: `90px repeat(${months.length}, 1fr)`, gap: 3 }}>
        <div style={{ fontSize: 10, color: "rgba(255,255,255,0.3)", padding: 8, fontFamily: "'DM Sans', sans-serif" }}></div>
        {months.map(m => (
          <div key={m} style={{ fontSize: 10, color: "rgba(255,255,255,0.4)", padding: 8, textAlign: "center", fontFamily: "'Space Mono', monospace", fontWeight: 600 }}>{m}</div>
        ))}
        {data.map(row => (
          <>
            <div key={row.cohort} style={{ fontSize: 11, color: "rgba(255,255,255,0.5)", padding: "8px 8px 8px 0", fontFamily: "'DM Sans', sans-serif", display: "flex", alignItems: "center" }}>{row.cohort}</div>
            {months.map((m, i) => {
              const key = `m${i}`;
              const val = row[key];
              return (
                <div key={`${row.cohort}-${m}`} style={{
                  background: getColor(val),
                  borderRadius: 6,
                  padding: 8,
                  textAlign: "center",
                  fontSize: 12,
                  fontWeight: 600,
                  color: val != null ? "#fff" : "transparent",
                  fontFamily: "'Space Mono', monospace",
                  transition: "transform 0.15s",
                  cursor: "default"
                }}
                  onMouseEnter={e => e.currentTarget.style.transform = "scale(1.08)"}
                  onMouseLeave={e => e.currentTarget.style.transform = "scale(1)"}
                >
                  {val != null ? `${val}%` : "—"}
                </div>
              );
            })}
          </>
        ))}
      </div>
    </div>
  );
};

const tabs = ["Overview", "Revenue", "Retention", "Activation"];

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState("Overview");

  const tooltipStyle = {
    backgroundColor: "rgba(15, 15, 20, 0.95)",
    border: "1px solid rgba(255,255,255,0.1)",
    borderRadius: 10,
    fontSize: 12,
    fontFamily: "'DM Sans', sans-serif",
    color: "#fff",
    padding: "8px 12px"
  };

  return (
    <div style={{
      minHeight: "100vh",
      background: "#0a0a0f",
      color: "#fff",
      fontFamily: "'DM Sans', sans-serif",
      position: "relative",
      overflow: "hidden"
    }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet" />

      {/* Ambient glow */}
      <div style={{ position: "fixed", top: -200, right: -200, width: 600, height: 600, background: "radial-gradient(circle, rgba(232,185,49,0.06) 0%, transparent 70%)", pointerEvents: "none" }} />
      <div style={{ position: "fixed", bottom: -200, left: -200, width: 500, height: 500, background: "radial-gradient(circle, rgba(78,205,196,0.04) 0%, transparent 70%)", pointerEvents: "none" }} />

      <div style={{ maxWidth: 1200, margin: "0 auto", padding: "0 24px" }}>
        {/* Header */}
        <header style={{ padding: "40px 0 32px", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 16 }}>
            <div>
              <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 8 }}>
                <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#4ECDC4", boxShadow: "0 0 12px rgba(78,205,196,0.5)" }} />
                <span style={{ fontSize: 10, fontWeight: 600, letterSpacing: 2, textTransform: "uppercase", color: "rgba(255,255,255,0.35)", fontFamily: "'Space Mono', monospace" }}>LIVE · dbt + DuckDB</span>
              </div>
              <h1 style={{ fontSize: 28, fontWeight: 700, margin: 0, letterSpacing: -0.5, lineHeight: 1.2 }}>
                SuperApp Lifecycle Analytics
              </h1>
              <p style={{ fontSize: 13, color: "rgba(255,255,255,0.35)", margin: "6px 0 0", maxWidth: 480 }}>
                Customer lifecycle intelligence across BNPL, food delivery, ride sharing & gaming · MENA region
              </p>
            </div>
            <div style={{ display: "flex", gap: 12, alignItems: "center", flexWrap: "wrap" }}>
              {["UAE", "KSA", "EGY", "KWT"].map(c => (
                <span key={c} style={{
                  fontSize: 10,
                  fontWeight: 600,
                  letterSpacing: 1,
                  padding: "5px 10px",
                  borderRadius: 6,
                  background: "rgba(255,255,255,0.04)",
                  border: "1px solid rgba(255,255,255,0.08)",
                  color: "rgba(255,255,255,0.5)",
                  fontFamily: "'Space Mono', monospace"
                }}>{c}</span>
              ))}
            </div>
          </div>

          {/* Tabs */}
          <div style={{ display: "flex", gap: 4, marginTop: 28 }}>
            {tabs.map(tab => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                style={{
                  padding: "8px 18px",
                  borderRadius: 8,
                  border: "none",
                  fontSize: 13,
                  fontWeight: 500,
                  fontFamily: "'DM Sans', sans-serif",
                  cursor: "pointer",
                  transition: "all 0.2s",
                  background: activeTab === tab ? "rgba(232,185,49,0.15)" : "transparent",
                  color: activeTab === tab ? "#E8B931" : "rgba(255,255,255,0.35)",
                  borderBottom: activeTab === tab ? "none" : "none"
                }}
              >
                {tab}
              </button>
            ))}
          </div>
        </header>

        {/* KPI Row */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", gap: 12, padding: "28px 0" }}>
          <KPICard label="Total GMV" value={formatCurrency(kpiData.totalGMV)} sub="Completed transactions" accent="#4ECDC4" />
          <KPICard label="Users" value={kpiData.totalUsers} sub="Across 4 markets" accent="#E8B931" />
          <KPICard label="Transactions" value={formatNumber(kpiData.totalTransactions)} sub={`${kpiData.completionRate}% completion rate`} accent="#A78BFA" />
          <KPICard label="Avg GMV/User" value={formatCurrency(kpiData.avgGMVPerUser)} sub="Lifetime value" accent="#FF6B6B" />
        </div>

        {/* Tab Content */}
        {activeTab === "Overview" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 20, paddingBottom: 40 }}>
            {/* Row 1: GMV Trend + Product Mix */}
            <div style={{ display: "grid", gridTemplateColumns: "1fr 340px", gap: 20 }}>
              <ChartCard>
                <SectionTitle subtitle="Monthly trend across all products">GMV Over Time</SectionTitle>
                <ResponsiveContainer width="100%" height={260}>
                  <AreaChart data={monthlyGMV}>
                    <defs>
                      <linearGradient id="gmvGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#E8B931" stopOpacity={0.25} />
                        <stop offset="100%" stopColor="#E8B931" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                    <XAxis dataKey="month" tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} tickFormatter={v => `$${v/1000}K`} />
                    <Tooltip contentStyle={tooltipStyle} formatter={(v) => [`$${v.toLocaleString()}`, "GMV"]} />
                    <Area type="monotone" dataKey="gmv" stroke="#E8B931" strokeWidth={2} fill="url(#gmvGrad)" />
                  </AreaChart>
                </ResponsiveContainer>
              </ChartCard>

              <ChartCard>
                <SectionTitle subtitle="Revenue share by vertical">Product Mix</SectionTitle>
                <ResponsiveContainer width="100%" height={180}>
                  <PieChart>
                    <Pie data={gmvByProduct} cx="50%" cy="50%" innerRadius={50} outerRadius={75} dataKey="gmv" paddingAngle={3} strokeWidth={0}>
                      {gmvByProduct.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                    </Pie>
                    <Tooltip contentStyle={tooltipStyle} formatter={(v) => [formatCurrency(v), "GMV"]} />
                  </PieChart>
                </ResponsiveContainer>
                <div style={{ display: "flex", flexDirection: "column", gap: 6, marginTop: 4 }}>
                  {gmvByProduct.map(p => (
                    <div key={p.product} style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                        <div style={{ width: 8, height: 8, borderRadius: 2, background: p.color }} />
                        <span style={{ fontSize: 12, color: "rgba(255,255,255,0.6)" }}>{p.product}</span>
                      </div>
                      <span style={{ fontSize: 12, fontFamily: "'Space Mono', monospace", color: "rgba(255,255,255,0.5)" }}>{p.pct}%</span>
                    </div>
                  ))}
                </div>
              </ChartCard>
            </div>

            {/* Row 2: Users by Country + Segment + Status */}
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 20 }}>
              <ChartCard>
                <SectionTitle subtitle="Distribution across MENA">Users by Market</SectionTitle>
                <div style={{ display: "flex", flexDirection: "column", gap: 10, marginTop: 8 }}>
                  {usersByCountry.map(c => (
                    <div key={c.country}>
                      <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                        <span style={{ fontSize: 13, color: "rgba(255,255,255,0.7)" }}>{c.country}</span>
                        <span style={{ fontSize: 12, fontFamily: "'Space Mono', monospace", color: "rgba(255,255,255,0.4)" }}>{c.users}</span>
                      </div>
                      <div style={{ height: 6, background: "rgba(255,255,255,0.04)", borderRadius: 3, overflow: "hidden" }}>
                        <div style={{ height: "100%", width: `${c.pct}%`, background: "linear-gradient(90deg, #4ECDC4, #45B7AA)", borderRadius: 3, transition: "width 1s ease" }} />
                      </div>
                    </div>
                  ))}
                </div>
              </ChartCard>

              <ChartCard>
                <SectionTitle subtitle="Avg lifetime GMV by tier">User Segments</SectionTitle>
                <ResponsiveContainer width="100%" height={180}>
                  <BarChart data={segmentBreakdown} barSize={36}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                    <XAxis dataKey="segment" tick={{ fontSize: 11, fill: "rgba(255,255,255,0.4)" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} tickFormatter={v => `$${v}`} />
                    <Tooltip contentStyle={tooltipStyle} formatter={(v) => [`$${v}`, "Avg GMV"]} />
                    <Bar dataKey="avgGMV" radius={[6, 6, 0, 0]}>
                      {segmentBreakdown.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </ChartCard>

              <ChartCard>
                <SectionTitle subtitle="Transaction completion rates">Payment Status</SectionTitle>
                <ResponsiveContainer width="100%" height={140}>
                  <PieChart>
                    <Pie data={statusBreakdown} cx="50%" cy="50%" innerRadius={38} outerRadius={58} dataKey="value" paddingAngle={4} strokeWidth={0}>
                      {statusBreakdown.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                    </Pie>
                    <Tooltip contentStyle={tooltipStyle} formatter={(v) => [`${v}%`]} />
                  </PieChart>
                </ResponsiveContainer>
                <div style={{ display: "flex", justifyContent: "center", gap: 16, marginTop: 4 }}>
                  {statusBreakdown.map(s => (
                    <div key={s.name} style={{ display: "flex", alignItems: "center", gap: 6 }}>
                      <div style={{ width: 6, height: 6, borderRadius: "50%", background: s.color }} />
                      <span style={{ fontSize: 11, color: "rgba(255,255,255,0.5)" }}>{s.name} {s.value}%</span>
                    </div>
                  ))}
                </div>
              </ChartCard>
            </div>
          </div>
        )}

        {activeTab === "Revenue" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 20, padding: "20px 0 40px" }}>
            <ChartCard>
              <SectionTitle subtitle="Monthly GMV and transaction volume">Revenue Trend</SectionTitle>
              <ResponsiveContainer width="100%" height={320}>
                <AreaChart data={monthlyGMV}>
                  <defs>
                    <linearGradient id="gmvGrad2" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#4ECDC4" stopOpacity={0.3} />
                      <stop offset="100%" stopColor="#4ECDC4" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                  <XAxis dataKey="month" tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} />
                  <YAxis yAxisId="gmv" tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} tickFormatter={v => `$${v/1000}K`} />
                  <YAxis yAxisId="txns" orientation="right" tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} />
                  <Tooltip contentStyle={tooltipStyle} />
                  <Area yAxisId="gmv" type="monotone" dataKey="gmv" stroke="#4ECDC4" strokeWidth={2} fill="url(#gmvGrad2)" name="GMV" />
                  <Line yAxisId="txns" type="monotone" dataKey="txns" stroke="#E8B931" strokeWidth={2} dot={false} name="Transactions" />
                </AreaChart>
              </ResponsiveContainer>
            </ChartCard>

            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 20 }}>
              <ChartCard>
                <SectionTitle subtitle="GMV contribution by product">Product Revenue</SectionTitle>
                <ResponsiveContainer width="100%" height={260}>
                  <BarChart data={gmvByProduct} layout="vertical" barSize={24}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" horizontal={false} />
                    <XAxis type="number" tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} tickFormatter={v => formatCurrency(v)} />
                    <YAxis type="category" dataKey="product" tick={{ fontSize: 12, fill: "rgba(255,255,255,0.5)" }} axisLine={false} tickLine={false} width={100} />
                    <Tooltip contentStyle={tooltipStyle} formatter={(v) => [formatCurrency(v), "GMV"]} />
                    <Bar dataKey="gmv" radius={[0, 6, 6, 0]}>
                      {gmvByProduct.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </ChartCard>

              <ChartCard>
                <SectionTitle subtitle="Transaction count per product">Volume Breakdown</SectionTitle>
                <ResponsiveContainer width="100%" height={260}>
                  <BarChart data={gmvByProduct} layout="vertical" barSize={24}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" horizontal={false} />
                    <XAxis type="number" tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} />
                    <YAxis type="category" dataKey="product" tick={{ fontSize: 12, fill: "rgba(255,255,255,0.5)" }} axisLine={false} tickLine={false} width={100} />
                    <Tooltip contentStyle={tooltipStyle} />
                    <Bar dataKey="txns" radius={[0, 6, 6, 0]} name="Transactions">
                      {gmvByProduct.map((entry, i) => <Cell key={i} fill={entry.color} opacity={0.7} />)}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </ChartCard>
            </div>
          </div>
        )}

        {activeTab === "Retention" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 20, padding: "20px 0 40px" }}>
            <ChartCard>
              <SectionTitle subtitle="Percentage of users returning each month after activation">Cohort Retention Heatmap</SectionTitle>
              <RetentionHeatmap data={retentionCohorts} />
            </ChartCard>

            <ChartCard>
              <SectionTitle subtitle="Retention curves by cohort">Retention Over Time</SectionTitle>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                  <XAxis dataKey="month" type="category" allowDuplicatedCategory={false}
                    tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false} />
                  <YAxis tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false}
                    domain={[0, 100]} tickFormatter={v => `${v}%`} />
                  <Tooltip contentStyle={tooltipStyle} formatter={v => [`${v}%`, "Retention"]} />
                  {retentionCohorts.map((cohort, idx) => {
                    const colors = ["#4ECDC4", "#E8B931", "#FF6B6B", "#A78BFA", "#45B7AA", "#F7DC6F"];
                    const lineData = Object.entries(cohort)
                      .filter(([k, v]) => k.startsWith("m") && v !== null)
                      .map(([k, v]) => ({ month: k.toUpperCase(), value: v }));
                    return (
                      <Line key={cohort.cohort} data={lineData} dataKey="value" name={cohort.cohort}
                        stroke={colors[idx % colors.length]} strokeWidth={2} dot={{ r: 3 }}
                        connectNulls={false} />
                    );
                  })}
                  <Legend wrapperStyle={{ fontSize: 11, color: "rgba(255,255,255,0.5)" }} />
                </LineChart>
              </ResponsiveContainer>
            </ChartCard>
          </div>
        )}

        {activeTab === "Activation" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 20, padding: "20px 0 40px" }}>
            <ChartCard>
              <SectionTitle subtitle="Cumulative % of users completing first transaction">Time to Activation</SectionTitle>
              <ResponsiveContainer width="100%" height={320}>
                <AreaChart data={activationData}>
                  <defs>
                    <linearGradient id="actGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#A78BFA" stopOpacity={0.3} />
                      <stop offset="100%" stopColor="#A78BFA" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                  <XAxis dataKey="day" tick={{ fontSize: 11, fill: "rgba(255,255,255,0.4)" }} axisLine={false} tickLine={false} />
                  <YAxis tick={{ fontSize: 10, fill: "rgba(255,255,255,0.3)" }} axisLine={false} tickLine={false}
                    domain={[0, 100]} tickFormatter={v => `${v}%`} />
                  <Tooltip contentStyle={tooltipStyle} formatter={v => [`${v}%`, "Activated"]} />
                  <Area type="monotone" dataKey="pct" stroke="#A78BFA" strokeWidth={2.5} fill="url(#actGrad)" dot={{ r: 4, fill: "#A78BFA" }} />
                </AreaChart>
              </ResponsiveContainer>
            </ChartCard>

            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 20 }}>
              <ChartCard>
                <div style={{ textAlign: "center", padding: "20px 0" }}>
                  <p style={{ fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: "uppercase", color: "rgba(255,255,255,0.35)", margin: "0 0 12px", fontFamily: "'DM Sans', sans-serif" }}>Day 7 Activation</p>
                  <p style={{ fontSize: 44, fontWeight: 700, color: "#4ECDC4", margin: 0, fontFamily: "'Space Mono', monospace" }}>62%</p>
                  <p style={{ fontSize: 12, color: "rgba(255,255,255,0.35)", marginTop: 6 }}>of users transact within 7 days</p>
                </div>
              </ChartCard>
              <ChartCard>
                <div style={{ textAlign: "center", padding: "20px 0" }}>
                  <p style={{ fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: "uppercase", color: "rgba(255,255,255,0.35)", margin: "0 0 12px", fontFamily: "'DM Sans', sans-serif" }}>Day 30 Activation</p>
                  <p style={{ fontSize: 44, fontWeight: 700, color: "#E8B931", margin: 0, fontFamily: "'Space Mono', monospace" }}>82%</p>
                  <p style={{ fontSize: 12, color: "rgba(255,255,255,0.35)", marginTop: 6 }}>within first month</p>
                </div>
              </ChartCard>
              <ChartCard>
                <div style={{ textAlign: "center", padding: "20px 0" }}>
                  <p style={{ fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: "uppercase", color: "rgba(255,255,255,0.35)", margin: "0 0 12px", fontFamily: "'DM Sans', sans-serif" }}>Median Activation</p>
                  <p style={{ fontSize: 44, fontWeight: 700, color: "#FF6B6B", margin: 0, fontFamily: "'Space Mono', monospace" }}>4.2d</p>
                  <p style={{ fontSize: 12, color: "rgba(255,255,255,0.35)", marginTop: 6 }}>days to first purchase</p>
                </div>
              </ChartCard>
            </div>
          </div>
        )}

        {/* Footer */}
        <footer style={{ borderTop: "1px solid rgba(255,255,255,0.06)", padding: "20px 0 32px", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 12 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <span style={{ fontSize: 11, color: "rgba(255,255,255,0.25)", fontFamily: "'Space Mono', monospace" }}>dbt 1.11 · DuckDB · 33 tests passing</span>
          </div>
          <span style={{ fontSize: 11, color: "rgba(255,255,255,0.2)" }}>Built by Fatima Farman · SuperApp Lifecycle Analytics</span>
        </footer>
      </div>
    </div>
  );
}
