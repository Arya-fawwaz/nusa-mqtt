import React, { useState } from 'react';
import './index.css';

function App() {
  const [battery, setBattery] = useState(85);
  const [solar, setSolar] = useState(4.2);
  const [load, setLoad] = useState(2.8);
  
  const [relays, setRelays] = useState([
    { id: 1, name: "Fasilitas Vital", state: true, priority: 1, icon: "🏥" },
    { id: 2, name: "Kebutuhan Dasar", state: true, priority: 2, icon: "🚰" },
    { id: 3, name: "Pendidikan", state: true, priority: 3, icon: "🏫" },
    { id: 4, name: "Aktivitas Produktif", state: false, priority: 4, icon: "🏭" },
    { id: 5, name: "Rumah Tangga", state: false, priority: 5, icon: "🏠" },
  ]);

  const toggleRelay = (id) => {
    setRelays(relays.map(r => r.id === id ? { ...r, state: !r.state } : r));
  };

  return (
    <div className="mobile-container">
      <header className="header">
        <div className="user-info">
          <h1>NUSA POWER</h1>
          <p>Desain Cerdas, Energi Berkelanjutan</p>
        </div>
        <div className="avatar">NP</div>
      </header>

      <div className="dashboard-content">
        <div className="hero-card">
          <div className="battery-ring">
            <svg viewBox="0 0 100 100" className="progress-svg">
              <circle cx="50" cy="50" r="45" className="bg-circle"></circle>
              <circle cx="50" cy="50" r="45" className="progress-circle" strokeDasharray="283" strokeDashoffset={283 - (283 * battery) / 100}></circle>
            </svg>
            <div className="battery-text">
              <span className="value">{battery}%</span>
              <span className="label">Baterai</span>
            </div>
          </div>
          <div className="stats-row">
            <div className="stat">
              <span className="icon">☀️</span>
              <div className="stat-info">
                <span className="val">{solar} kW</span>
                <span className="lbl">Produksi</span>
              </div>
            </div>
            <div className="stat">
              <span className="icon">⚡</span>
              <div className="stat-info">
                <span className="val">{load} kW</span>
                <span className="lbl">Beban</span>
              </div>
            </div>
          </div>
        </div>

        <div className="section-title">
          <h2>Rekomendasi AI</h2>
          <span className="badge warning">Warning</span>
        </div>
        <div className="ai-card">
          <p className="ai-text">
            Baterai turun di bawah 90%. Disarankan mematikan <strong>Rumah Tangga</strong> untuk menjaga <strong>Fasilitas Vital</strong> semalaman.
          </p>
          <button className="apply-btn">Terapkan Otomatis</button>
        </div>

        <div className="section-title">
          <h2>Kontrol Beban (Smart Relay)</h2>
        </div>
        
        <div className="relay-list">
          {relays.map(relay => (
            <div className={`relay-card ${relay.state ? 'active' : ''}`} key={relay.id} onClick={() => toggleRelay(relay.id)}>
              <div className="relay-icon">{relay.icon}</div>
              <div className="relay-info">
                <h3>{relay.name}</h3>
                <p>Prioritas {relay.priority}</p>
              </div>
              <div className="toggle-switch">
                <div className={`switch-knob ${relay.state ? 'on' : 'off'}`}></div>
              </div>
            </div>
          ))}
        </div>
      </div>
      
      <nav className="bottom-nav">
        <div className="nav-item active">🏠</div>
        <div className="nav-item">📊</div>
        <div className="nav-item">🤖</div>
        <div className="nav-item">⚙️</div>
      </nav>
    </div>
  );
}

export default App;
