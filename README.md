<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="#">
    <img src="https://img.icons8.com/fluency/96/server.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">KSQLDB Workshop</h3>

  <p align="center">
    สุดยอดคู่มือการเรียนรู้ KSQLDB แบบ Step-by-Step
    <br />
    <a href="#getting-started"><strong>สำรวจเอกสาร »</strong></a>
    <br />
    <br />
    <a href="#">ดู Demo</a>
    ·
    <a href="#">แจ้งปัญหา</a>
    ·
    <a href="#">ขอฟีเจอร์ใหม่</a>
  </p>
</div>

<!-- BADGES -->
<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/github_username/repo_name.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

</div>

---

<!-- TABLE OF CONTENTS -->
<details>
  <summary>สารบัญ (คลิกเพื่อขยาย)</summary>
  <ol>
    <li>
      <a href="#about-the-project">เกี่ยวกับโปรเจกต์</a>
      <ul>
        <li><a href="#built-with">เทคโนโลยีที่ใช้</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">เริ่มต้นใช้งาน</a>
      <ul>
        <li><a href="#prerequisites">สิ่งที่ต้องมี</a></li>
        <li><a href="#installation">การติดตั้ง</a></li>
      </ul>
    </li>
    <li><a href="#usage">วิธีการใช้งาน</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contact">ติดต่อ</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## 🚀 เกี่ยวกับโปรเจกต์

Workshop นี้ถูกออกแบบมาเพื่อช่วยให้คุณเข้าใจการทำงานของ KSQLDB ตั้งแต่พื้นฐานจนถึงการประยุกต์ใช้งานจริง ผ่านการลงมือทำ Hands-on Lab ที่เข้าใจง่าย

จุดเด่นของ Workshop:
* 🎯 **Hands-on**: เน้นลงมือทำจริง ไม่ใช่แค่ทฤษฎี
* ⚡ **Fast**: เนื้อหากระชับ เรียนรู้ไว
* 🛠️ **Real-world**: ตัวอย่าง Use Case จากสถานการณ์จริง

<p align="right">(<a href="#readme-top">กลับไปด้านบน</a>)</p>

<!-- BUILT WITH -->
### 🛠️ เทคโนโลยีที่ใช้

* [![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
* [![Kafka](https://img.shields.io/badge/Apache_Kafka-231F20?style=for-the-badge&logo=apache-kafka&logoColor=white)](https://kafka.apache.org/)
* [![KSQLDB](https://img.shields.io/badge/ksqlDB-000000?style=for-the-badge&logo=ksqldb&logoColor=white)](https://ksqldb.io/)

<!-- GETTING STARTED -->
## ⚡ เริ่มต้นใช้งาน

ทำตามขั้นตอนด้านล่างเพื่อรัน Environment สำหรับ Workshop นี้

### สิ่งที่ต้องมี

* Docker Desktop
* Git

### การติดตั้ง

1. Clone repo
   ```sh
   git clone https://github.com/your_username/KSQLDB-Workshop.git
   ```
2. เข้าสู่โฟลเดอร์
   ```sh
   cd KSQLDB-Workshop
   ```
3. รัน Docker Compose
   ```sh
   docker-compose up -d
   ```

<!-- USAGE EXAMPLES -->
## 💻 ตัวอย่างการใช้งาน

ตัวอย่างคำสั่งพื้นฐานในการสร้าง Stream:

```sql
CREATE STREAM users_stream (id VARCHAR, name VARCHAR) 
  WITH (KAFKA_TOPIC='users', VALUE_FORMAT='JSON');
```

<p align="right">(<a href="#readme-top">กลับไปด้านบน</a>)</p>

<!-- AUTHOR -->
## 👤 ผู้จัดทำ

**Workshop Team**
* Website: [example.com](https://example.com)

---

<div align="center">
  ⭐️ ถ้าชอบโปรเจกต์นี้ อย่าลืมกด Star ให้ด้วยนะครับ! ⭐️
</div>