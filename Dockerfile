# Use a lightweight official Python runtime for the test stage.
FROM python:3.9-slim AS test

# Set the working directory for test execution.
WORKDIR /app

# Copy dependency definitions first to leverage Docker layer caching.
COPY requirements.txt .

# Install Python dependencies without storing pip's download cache.
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source and tests needed for unit testing.
COPY . .

# Run unit tests; Docker build fails here if any test fails.
RUN python -m unittest discover tests

# Write a marker file so later stages can depend on this tested stage.
RUN touch /tests-passed

# Use a separate lightweight runtime stage for the final image.
FROM python:3.9-slim AS runtime

# Set the working directory for the running application.
WORKDIR /app

# Copy dependency definitions first to leverage Docker layer caching.
COPY requirements.txt .

# Install runtime Python dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# Ensure the final image build depends on the successful test stage.
COPY --from=test /tests-passed /tests-passed

# Copy only runtime application files into the final image.
COPY app ./app
COPY run.py .

# Document that the containerized app listens on port 5000.
EXPOSE 5000

# Start the Flask application when the container runs.
CMD ["python", "run.py"]