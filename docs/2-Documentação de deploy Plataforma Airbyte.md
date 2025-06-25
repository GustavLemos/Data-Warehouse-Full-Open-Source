# Deploy do Airbyte com `abctl` em EC2

**Autor:** Gustavo Lemos (Arquiteto de Dados)  
**Data:** 24/06/2025  

---

## Visão Geral

Este guia descreve como instalar o Airbyte em uma instância EC2 utilizando a ferramenta `abctl`, com base no sistema operacional Amazon Linux.

---

## Pré-requisitos

- Instância EC2 (Amazon Linux)
- Chave SSH para acesso à instância
- Segurança configurada para liberar a porta usada (padrão: `8000`)
- Domínio público ou IP fixo para acesso externo (recomendado)

---

## 1. Acessar a Instância EC2

```bash
ssh -i "sua-chave.pem" ec2-user@IP_DA_INSTANCIA
````

---

## 2. Instalar o Docker

```bash
sudo yum install -y docker
sudo usermod -a -G docker ec2-user
sudo systemctl start docker
sudo systemctl enable docker
```

**Importante:** Após isso, saia da sessão e reconecte para aplicar o grupo:

```bash
exit
ssh -i "sua-chave.pem" ec2-user@IP_DA_INSTANCIA
```

---

## 3. Instalar o `abctl`

```bash
curl -LsfS https://get.airbyte.com | bash -
```

Isso adicionará o `abctl` ao seu `$PATH`.

---

## 4. Instalar o Airbyte com `abctl`

Com o domínio público (ou IP fixo) da sua instância:

```bash
abctl local install --host SEU_DOMINIO_OU_IP_PUBLICO
```

Se desejar rodar com HTTP (inseguro), adicione o parâmetro `--insecure-cookies`:

```bash
abctl local install --host SEU_DOMINIO_OU_IP_PUBLICO --insecure-cookies
```

Se desejar utilizar outra porta, especifique com `--port`:

```bash
abctl local install --host SEU_DOMINIO_OU_IP_PUBLICO --port 8080
```

---

## 5. Configuração de Segurança (Security Group)

Certifique-se de que o grupo de segurança da instância EC2 permite entrada na porta escolhida (padrão: `8000`).

Portas recomendadas:

* `8000` (ou a definida com `--port`) — Interface Web do Airbyte
* `22` — SSH

---

## 6. Acesso ao Airbyte

Após a instalação, acesse no navegador:

```
http://SEU_DOMINIO_OU_IP_PUBLICO:8000
```

---

## 7. Credenciais Padrão

O Airbyte possui apenas **um único usuário** padrão. As credenciais são definidas durante o primeiro acesso.

---

## 8. Parar o Airbyte

```bash
abctl local down
```

---

## Referências

* [Documentação oficial do Airbyte](https://docs.airbyte.io)
* [Documentação do `abctl` no EC2](https://docs.airbyte.com/platform/deploying-airbyte/abctl-ec2)
* [Documentação AWS EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html)


