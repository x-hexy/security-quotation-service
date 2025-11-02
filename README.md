# 🛡️ Security Quotation Service

An **end-to-end MVP** for a *Security Guard Quotation Platform*, enabling customers to request site-based security quotations and receive estimated options automatically.

---

## 📦 Tech Stack

| Layer | Technology | Description |
|-------|-------------|-------------|
| **Frontend** | Vue 3 + Vite + Axios | User interface for submitting quotation requests |
| **Backend** | Spring Boot (Java 17) | REST API server handling requests and generating quotations |
| **Database** | PostgreSQL (Docker) | Stores customer, site, request, and quotation data |

---

## 🧱 Project Structure

```
security-quotation-service/
├── backend/
│   ├── src/main/java/com/example/secquote/
│   ├── pom.xml
│
├── frontend-vue/
│   ├── src/
│   └── package.json
│
├── security_estimate_a5m2.sql
└── README.md
```

---

## ⚙️ Setup Instructions

### 1️⃣ Start PostgreSQL (Docker)

```bash
docker run -d ^
  --name secdb ^
  -e POSTGRES_USER=postgres ^
  -e POSTGRES_PASSWORD=postgres ^
  -e POSTGRES_DB=security_estimate ^
  -p 5432:5432 ^
  -v ${PWD}:/docker-entrypoint-initdb.d ^
  postgres:16
```

### 2️⃣ Run Backend (Spring Boot)

```bash
cd backend
mvn clean package -DskipTests
mvn spring-boot:run
```

App: [http://localhost:8080](http://localhost:8080)

### 3️⃣ Run Frontend (Vue 3)

```bash
cd frontend-vue
npm install
npm run dev -- --host
```

Frontend: [http://localhost:5173](http://localhost:5173)

---

## 🧩 Environment

| Component | Version |
|------------|----------|
| Java | 17 |
| Spring Boot | 3.3.x |
| PostgreSQL | 16 |
| Node | ≥18 |
| npm | ≥9 |

---

## 🛠️ Troubleshooting

| Symptom | Cause | Fix |
|----------|--------|-----|
| `site not found` | DB missing site | Insert sample site |
| `ByteBuddyInterceptor` | Lazy JPA serialization | Return DTO in controller |
| `CORS blocked` | Missing CORS config | Add `@CrossOrigin` |
| `ApplicationContext` fail | DB not running | Start DB or use `-DskipTests` |

---

## 🚀 Future Roadmap

- JWT authentication
- Quotation calculation logic
- Admin dashboard
- Docker Compose deployment

---

## 🏁 License

MIT License © 2025 Security Quotation MVP Project
