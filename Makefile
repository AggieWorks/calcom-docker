.PHONY: help setup env pull run stop clean logs

# Default target
help:
	@echo "Cal.com Docker Setup and Management"
	@echo ""
	@echo "Usage:"
	@echo "  make help             Show this help message"
	@echo "  make setup            Initial setup (copy .env.example to .env and generate secrets)"
	@echo "  make env              Update environment variables with custom values"
	@echo "  make pull             Pull the latest Docker images"
	@echo "  make run              Run the services in detached mode"
	@echo "  make stop             Stop all services"
	@echo "  make clean            Stop and remove containers, networks, and volumes"
	@echo "  make logs             Show logs of running containers"
	@echo ""

# Setup environment file with proper values
setup:
	@echo "Setting up Cal.com environment..."
	@if [ ! -f .env ]; then \
		cp calcom/.env.example .env; \
		sed -i '' 's/NEXT_PUBLIC_LICENSE_CONSENT=.*/NEXT_PUBLIC_LICENSE_CONSENT=agree/g' .env; \
		sed -i '' 's/LICENSE=.*/LICENSE=agree/g' .env; \
		sed -i '' 's/NEXT_PUBLIC_WEBAPP_URL=.*/NEXT_PUBLIC_WEBAPP_URL=http:\/\/localhost:3000/g' .env; \
		sed -i '' 's/NEXT_PUBLIC_API_V2_URL=.*/NEXT_PUBLIC_API_V2_URL=http:\/\/localhost:5555\/api\/v2/g' .env; \
		echo "Generating NEXTAUTH_SECRET..."; \
		NEXTAUTH_SECRET=$$(openssl rand -base64 32); \
		sed -i '' "s/NEXTAUTH_SECRET=.*/NEXTAUTH_SECRET=$$NEXTAUTH_SECRET/g" .env; \
		echo "Generating CALENDSO_ENCRYPTION_KEY..."; \
		CALENDSO_ENCRYPTION_KEY=$$(dd if=/dev/urandom bs=1K count=1 2>/dev/null | md5); \
		sed -i '' "s/CALENDSO_ENCRYPTION_KEY=.*/CALENDSO_ENCRYPTION_KEY=$$CALENDSO_ENCRYPTION_KEY/g" .env; \
		sed -i '' 's/POSTGRES_USER=.*/POSTGRES_USER=unicorn_user/g' .env; \
		sed -i '' 's/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=magical-password/g' .env; \
		sed -i '' 's/POSTGRES_DB=.*/POSTGRES_DB=calendso/g' .env; \
		sed -i '' 's/DATABASE_HOST=.*/DATABASE_HOST=database:5432/g' .env; \
		echo "Environment file created successfully!"; \
	else \
		echo ".env file already exists. Use 'make env' to modify it."; \
	fi

# Update environment variables interactively
env:
	@echo "Updating environment variables..."
	@read -p "NEXT_PUBLIC_WEBAPP_URL [http://localhost:3000]: " webapp_url; \
	if [ -n "$$webapp_url" ]; then \
		sed -i '' "s|NEXT_PUBLIC_WEBAPP_URL=.*|NEXT_PUBLIC_WEBAPP_URL=$$webapp_url|g" .env; \
	fi
	@read -p "POSTGRES_USER [unicorn_user]: " pg_user; \
	if [ -n "$$pg_user" ]; then \
		sed -i '' "s|POSTGRES_USER=.*|POSTGRES_USER=$$pg_user|g" .env; \
	fi
	@read -p "POSTGRES_PASSWORD [magical-password]: " pg_pass; \
	if [ -n "$$pg_pass" ]; then \
		sed -i '' "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$$pg_pass|g" .env; \
	fi
	@read -p "POSTGRES_DB [calendso]: " pg_db; \
	if [ -n "$$pg_db" ]; then \
		sed -i '' "s|POSTGRES_DB=.*|POSTGRES_DB=$$pg_db|g" .env; \
	fi
	@echo "Environment variables updated!"

# Pull latest Docker images
pull:
	@echo "Pulling latest Docker images..."
	docker compose pull

# Run services in detached mode
run:
	@echo "Starting Cal.com services..."
	docker compose up -d
	@echo "Services started! Access Cal.com at http://localhost:3000"

# Stop services
stop:
	@echo "Stopping services..."
	docker compose down

# Stop and remove containers, networks, and volumes
clean:
	@echo "Cleaning up resources..."
	docker compose down -v

# Show logs
logs:
	@echo "Showing logs..."
	docker compose logs -f
