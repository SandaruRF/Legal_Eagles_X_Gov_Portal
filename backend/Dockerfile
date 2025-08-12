
FROM python:3.12.3-slim

WORKDIR /code

# Create a non-root user and its home directory
RUN useradd --create-home appuser

ENV PATH="/home/appuser/.local/bin:${PATH}"

USER appuser

COPY --chown=appuser:appuser requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser ./app ./app

RUN prisma generate --schema=./app/prisma/schema.prisma

EXPOSE 7860

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
