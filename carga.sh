#!/bin/bash

DATA=`date '+%g%m%d-%H%M'`


START=$(date +%s)
DATAINICIO=`date '+%g%m%d-%H%M%S'`

cd /tmp/script_migracao/
node index.js migration -i ${INICIO} -f ${FIM} -l 1000
tar cfz logs.tar.gz logs/
# Envia para o S3
aws s3 cp logs.tar.gz s3://bucket_de_logs/$AWS_BATCH_JOB_ID.tar.gz
# Cria link temporario do arquivo
LINKARQUIVO=`aws s3 presign s3://bucket_de_logs/$AWS_BATCH_JOB_ID.tar.gz --expires-in 172800`

cd /tmp
sleep 1
END=$(date +%s)
DATAFIM=`date '+%g%m%d-%H%M%S'`

DIFF=$(( $END - $START ))
RANGE=$(($FIM-$INICIO))

VELOCIDADE=$(($RANGE/$DIFF))

# Criacao do texto do email
echo "{
      \"Subject\": {
          \"Data\": \"Carga - ${AWS_BATCH_JOB_ID}\",
          \"Charset\": \"UTF-8\"
      },
      \"Body\": {
          \"Html\": {
              \"Data\": \"Arquivo disponível no S3: <a class=\\\"ulink\\\" href=\\\"$LINKARQUIVO\\\" target=\\\"_blank\\\">$AWS_BATCH_JOB_ID.tar.gz</a><br>Inicio: $DATAINICIO<br>Fim: $DATAFIM<br>Execução: $DIFF segundos<br>Velocidade: $VELOCIDADE records/second<br>\",
              \"Charset\": \"UTF-8\"
          }
      }
   }" > message.json

# Envia email
aws ses send-email --from relatorio@meudominio.com.br --destination ToAddresses=relatorio@meudominio.com.br --message fileb://message.json --region us-east-1
