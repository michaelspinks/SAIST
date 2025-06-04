FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copy SAIST source code from the repository
COPY saist/ /app/saist/
COPY setup.py /app/
COPY requirements.txt /app/
COPY README.md /app/

# Install SAIST from local source
WORKDIR /app
RUN pip install -e .

# Copy action scripts
COPY .github/actions/saist-scanner/entrypoint.sh /entrypoint.sh
COPY .github/actions/saist-scanner/scripts/ /scripts/

RUN chmod +x /entrypoint.sh
RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/entrypoint.sh"]
