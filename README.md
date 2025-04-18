<!-- PROJECT LOGO -->
<p align="center">
  <a href="https://github.com/calcom/cal.com">
    <img src="https://user-images.githubusercontent.com/8019099/133430653-24422d2a-3c8d-4052-9ad6-0580597151ee.png" alt="Logo">

  </a>

  <h3 align="center">Cal.com (formerly Calendso)</h3>

  <p align="center">
    The open-source Calendly alternative. (Docker Edition)
    <br />
    <a href="https://cal.com"><strong>Learn more »</strong></a>
  </p>
</p>

# Docker

This image can be found on DockerHub at [https://hub.docker.com/r/calcom/cal.com](https://hub.docker.com/r/calcom/cal.com)


# Github repo

The official github repo for cal.com can be found at [https://github.com/calcom/docker](https://github.com/calcom/docker)

## Requirements

Make sure you have `docker` & `docker compose` installed on the server / system. Both are installed by most docker utilities, including Docker Desktop and Rancher Desktop.

Note: `docker compose` without the hyphen is now the primary method of using docker-compose, per the Docker documentation.

## Running Cal.com with Docker Compose


1. Clone calcom/docker

    ```bash
    git clone https://github.com/calcom/docker.git
    ```

2. Change into the directory

    ```bash
    cd docker
    ```

3. Prepare your configuration: Rename `.env.example` to `.env` and then update `.env`

    ```bash
    cp .env.example .env
    ```

    Most configurations can be left as-is, but for configuration options see [Important Run-time variables](#important-run-time-variables) below.

    Update the appropriate values in your .env file, then proceed.

4. (optional) Pre-Pull the images by running the following command:

    ```bash
    docker compose pull
    ```

    This will use the default image locations as specified by `image:` in the docker-compose.yaml file.

    Note: To aid with support, by default Scarf.sh is used as registry proxy for download metrics.

5. Start Cal.com via docker compose

    (Most basic users, and for First Run) To run the complete stack, which includes a local Postgres database, Cal.com web app, and Prisma Studio:

    ```bash
    docker compose up -d
    ```

    To run Cal.com web app and Prisma Studio against a remote database, ensure that DATABASE_URL is configured for an available database and run:

    ```bash
    docker compose up -d calcom studio
    ```

    To run only the Cal.com web app, ensure that DATABASE_URL is configured for an available database and run:

    ```bash
    docker compose up -d calcom
    ```

    **Note: to run in attached mode for debugging, remove `-d` from your desired run command.**

6. PSQL environment variable setup

    

7. Open a browser to [http://localhost:3000](http://localhost:3000), or your defined NEXT_PUBLIC_WEBAPP_URL. The first time you run Cal.com, a setup wizard will initialize. Define your first user, and you're ready to go!

## Updating Cal.com

1. Stop the Cal.com stack

    ```bash
    docker compose down
    ```

2. Pull the latest changes

    ```bash
    docker compose pull
    ```
3. Update env vars as necessary.
4. Re-start the Cal.com stack

    ```bash
    docker compose up -d
    ```

## Configuration

### Important Run-time variables

These variables must also be provided at runtime

| Variable | Description | Required | Default |
| --- | --- | --- | --- |
| CALCOM_LICENSE_KEY | Enterprise License Key | optional |  |
| NEXT_PUBLIC_WEBAPP_URL | Base URL of the site.  NOTE: if this value differs from the value used at build-time, there will be a slight delay during container start (to update the statically built files). | optional | `http://localhost:3000` |
| NEXTAUTH_URL | Location of the auth server. By default, this is the Cal.com docker instance itself. | optional | `{NEXT_PUBLIC_WEBAPP_URL}/api/auth` |
| NEXTAUTH_SECRET | must match build variable | required | `secret` |
| CALENDSO_ENCRYPTION_KEY | must match build variable | required | `secret` |
| DATABASE_URL | database url with credentials - if using a connection pooler, this setting should point there | required | `postgresql://unicorn_user:magical_password@database:5432/calendso` |
| DATABASE_DIRECT_URL | direct database url with credentials if using a connection pooler (e.g. PgBouncer, Prisma Accelerate, etc.) | optional | |

### Build-time variables

If building the image yourself, these variables must be provided at the time of the docker build, and can be provided by updating the .env file. Currently, if you require changes to these variables, you must follow the instructions to build and publish your own image.

Updating these variables is not required for evaluation, but is required for running in production. Instructions for generating variables can be found in the [cal.com instructions](https://github.com/calcom/cal.com)

| Variable | Description | Required | Default |
| --- | --- | --- | --- |
| NEXT_PUBLIC_WEBAPP_URL | Base URL injected into static files | optional | `http://localhost:3000` |
| NEXT_PUBLIC_LICENSE_CONSENT | license consent - true/false |  |  |
| CALCOM_TELEMETRY_DISABLED | Allow cal.com to collect anonymous usage data (set to `1` to disable) | | |
| DATABASE_URL | database url with credentials - if using a connection pooler, this setting should point there | required | `postgresql://unicorn_user:magical_password@database:5432/calendso` |
| DATABASE_DIRECT_URL | direct database url with credentials if using a connection pooler (e.g. PgBouncer, Prisma Accelerate, etc.) | optional | |
| NEXTAUTH_SECRET | Cookie encryption key | required | `secret` |
| CALENDSO_ENCRYPTION_KEY | Authentication encryption key | required | `secret` |

## Git Submodules

This repository uses a git submodule.

For users building their own images, to update the calcom submodule, use the following command:

```bash
git submodule update --remote --init
```

For more advanced usage, please refer to the git documentation: [https://git-scm.com/book/en/v2/Git-Tools-Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

## Troubleshooting

### 1. Network Stack  
Cal.com and Postgres must share the same Docker network as defined in `docker-compose.yml`.  
- List all networks:  
    ```bash
    docker network ls
    ```  
- Identify the project network (usually `docker_default`):  
    ```bash
    docker network inspect docker_default
    ```  
- From inside the Cal.com container, verify it can reach the database host:  
    ```bash
    docker exec -it calcom ping -c 4 database
    ```  
  If pings fail, ensure the `docker-compose.yml` has no custom network names or typos under `services: … networks:`.

### 2. Pre‑existing Data in the Cal.com Database  
The Postgres service (`database`) must contain the required schema and seed data.  
- List tables in the `calendso` database:  
    ```bash
    docker exec -it database \
      psql -U unicorn_user -d calendso -c "\dt"
    ```  
- Check Cal.com container logs for migration errors:  
    ```bash
    docker logs calcom
    ```  
- If tables are missing, restore from SQL dump:  
    ```bash
    docker exec -i database \
      psql -U unicorn_user -d calendso < backup.sql
    ```  
  Then restart Cal.com to re‑run migrations:
    ```bash
    docker compose restart calcom
    ```

### 3. Build Order & Common Issues  
Follow these steps in order to avoid build or startup failures:  
1. Clone the repo and enter it:  
    ```bash
    git clone https://github.com/calcom/docker.git
    cd docker
    ```  
2. Copy and edit environment variables:  
    ```bash
    cp .env.example .env
    # Update NEXTAUTH_SECRET, CALENDSO_ENCRYPTION_KEY, etc.
    ```  
3. (Optional) Pre-pull images:  
    ```bash
    docker compose pull
    ```  
4. Launch the full stack:  
    ```bash
    docker compose up -d
    ```  

Common issues:  
- **Out of memory / RAM errors**  
  Increase Docker’s resource allocation (e.g., Docker Desktop → Preferences → Resources).  
- **`ERROR: .env file not found`**  
  Ensure the file is named exactly `.env` (no extension or hidden characters).  
- **Incorrect platform error**  
  If you see messages like `no matching manifest for linux/arm64/v8` or `exec format error`, you can:  
  1. Specify a platform in `docker-compose.yml`:  
     ```yaml
     services:
       calcom:
         platform: linux/amd64
     ```  
  2. Or run with a platform flag:  
     ```bash
     docker compose up -d --platform linux/amd64
     ```  

### 4. Updating Env Configurations After Deployment  
Whenever you change any database credentials or other `.env` values, you must fully tear down volumes so services pick up the new settings:  
```bash
docker compose down -v      # stops containers and removes named volumes
# edit .env with your new values
docker compose up -d        # rebuilds containers with updated environment
```  
> Warning: `-v` deletes persistent data. Backup your database before running the teardown if you need to preserve existing records.
