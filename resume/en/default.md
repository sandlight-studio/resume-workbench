<div class="resume-header">
<div class="resume-header__name-block">
<h1>San Zhang</h1>
</div>
<div class="resume-header__meta-block">
<p class="resume-header__role">Software Engineer</p>
<p class="resume-header__personal">Example City · Bachelor's Degree</p>
<p class="resume-header__contact">(+00) 000-0000-0000 · zhangsan@example.com</p>
</div>
</div>

## Professional Summary

- Five years of fictional software-engineering experience across backend services, asynchronous jobs, and operational tooling.
- Comfortable defining idempotency, retry, observability, and recovery behavior before implementation.
- Experienced with Java, relational databases, caching, messaging, automated tests, and delivery workflows.

## Work Experience

| | | |
|---|---|---|
| Mar 2021 - Present | Example Technology Ltd. | Software Engineer |
| Jul 2017 - Feb 2021 | Demo Cloud Services Ltd. | Java Developer |

## Selected Projects

### Collaborative Task Platform | Example Technology Ltd.

Jan 2023 - Present | Core Developer

**Stack:** Java, Spring Boot, MySQL, Redis, RabbitMQ, Docker

- Persisted incoming events before publishing messages and made consumers idempotent through event keys and explicit processing states.
- Combined tenant-scoped caching with database uniqueness constraints so correctness did not depend on cache availability.
- Added retry history, terminal failure states, and replay tooling to make recovery observable and controlled.

### Asynchronous Reporting Center | Example Technology Ltd.

Mar 2021 - Dec 2022 | Backend Developer

**Stack:** Java, Spring Boot, PostgreSQL, Redis, object storage

- Replaced synchronous exports with durable jobs, cursor-based reads, and streaming file generation.
- Added bounded concurrency and per-tenant quotas to keep large reports from starving online traffic.
- Used scheduled reconciliation to recover jobs whose queue messages were delayed or lost.

### Enterprise Notification Service | Demo Cloud Services Ltd.

Apr 2018 - Feb 2021 | Java Developer

**Stack:** Java, Spring MVC, MySQL, Redis

- Unified email, in-app, and webhook delivery behind a versioned notification contract.
- Classified transient and permanent failures so invalid requests could not retry forever.

## Technical Skills

**Backend:** Java, Spring Boot, REST APIs, transactions, concurrency, and testing.

**Data and messaging:** MySQL, PostgreSQL, Redis, RabbitMQ, indexing, caching, and reliable delivery patterns.

**Engineering:** Git, Docker, Gradle, Maven, structured logging, metrics, tracing, and continuous integration.

## Education

| | | |
|---|---|---|
| Sep 2013 - Jun 2017 | Example University | B.Eng. in Software Engineering |
