# DCV Launchable - Justfile for deployment commands

COMPOSE_LAUNCHER := "docker compose"

# Build Docker images
build:
    {{COMPOSE_LAUNCHER}} build

# Launch containers
launch:
    {{COMPOSE_LAUNCHER}} up -d

# Deploy (build and launch)
deploy: build launch
    @echo "=========================================="
    @echo "DCV Launchable Deployment Complete!"
    @echo "=========================================="
    @echo ""
    @echo "Waiting for services to start..."
    @sleep 10
    @{{COMPOSE_LAUNCHER}} ps
    @echo ""
    @echo "Access your DCV desktop:"
    @echo "  Web Client: https://$(curl -s ifconfig.me):8443"
    @echo "  SSH Access: ssh ubuntu@$(curl -s ifconfig.me)"
    @echo ""
    @echo "Credentials:"
    @echo "  Username: ubuntu"
    @echo "  Password: 1234"
    @echo ""
    @echo "Check logs with:"
    @echo "  just logs"
    @echo "=========================================="

# Show logs
logs:
    {{COMPOSE_LAUNCHER}} logs -f

# Show status
status:
    {{COMPOSE_LAUNCHER}} ps

# Stop containers
stop:
    {{COMPOSE_LAUNCHER}} down

# Restart containers
restart: stop launch

# Clean up (remove containers, images, volumes)
clean:
    {{COMPOSE_LAUNCHER}} down -v --rmi all
