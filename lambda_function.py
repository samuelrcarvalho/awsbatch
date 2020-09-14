import json, boto3

def lambda_handler(event, context):
    
    lote = 100000

    dynamodb = boto3.resource('dynamodb')
    
    table = dynamodb.Table('controle')
    
    try:    
        response = table.get_item(Key={'index': 'contador'})
    except:
        print('Erro ao pegar index')
        print(response)
    
    print('Index Lido')
    print(response)
    
    referencia = (response['Item']['nome'])
    ultimo = (response['Item']['ultimo'])
    
    
    inicio = int(ultimo) - lote
    fim = int(ultimo)
    nome = int(referencia) + 1
    
        # submeter job
    client = boto3.client('batch')
    
    try:
        response = client.submit_job(
            jobName=str(nome),
            jobQueue='fila',
            jobDefinition='carga:1',
            containerOverrides={
                'environment': [
                    {
                        'name': 'INICIO',
                        'value': str(inicio)
                    },
                    {
                        'name': 'FIM',
                        'value': str(fim)
                    },
                ]
            }
        )
    except:
        print('Erro ao submeter job')
        print(response)
        
    print('Job Submetido')
    print(response)
    
    uuidrequest=(response['jobId'])
    
    try:
        response = table.put_item(
               Item={
                    'index': str(uuidrequest),
                    'inicio': inicio,
                    'fim': fim,
                    'nome': nome
                }
            )
    except:
        print('Erro ao salvar historico')
        print(response)
        
    print('Historico Salvo')
    print(response)
    
    # atualizar contador
    try:
        response = table.update_item(
            Key={
                'index': 'contador',
            }, 
            UpdateExpression='SET ultimo=:u, nome=:n',
            ExpressionAttributeValues={
                ':u': inicio,
                ':n': nome
            },
            ReturnValues="UPDATED_NEW"
        )
    except:
        print('Erro ao salvar controle')
        print(response)
    
    print('Controle atualizado')
    print(response)

    return {
        'statusCode': 200,
        'body': json.dumps(str(uuidrequest))
    }

