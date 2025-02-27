# Ambiente Docker para PHP e MariaDB

Este projeto configura um ambiente Docker simples para desenvolvimento com PHP 7.4 (ou outra versão) e MariaDB 10.6. O ambiente inclui um servidor PHP embutido e um banco de dados MariaDB, permitindo que você desenvolva e teste aplicações PHP com facilidade.
## Pré-requisitos

  - Docker instalado na máquina.

  - Docker Compose instalado na máquina.

## Estrutura do Projeto

  - `Dockerfile`: Contém a configuração da imagem Docker para o PHP 7.4, incluindo extensões necessárias e o Composer.

  - `docker-compose.yml`: Define os serviços app (PHP) e db (MariaDB), além de configurar a rede e volumes.

  - `src/`: Diretório onde o código-fonte da aplicação PHP deve ser colocado.

  - `config.php`, `constants.php`, `database.php`: Arquivos de configuração da aplicação PHP.

## Configuração
Arquivos de Configuração

  - `config.php`: Configura o caminho de salvamento da sessão.
  ```php
  $config['sess_save_path'] = sys_get_temp_dir();
  ```
  - `constants.php`: Define o nome do projeto.
  ```php
  define("PROJECT_NAME","/");
  ```
  - `database.php`: Configura as credenciais do banco de dados
  ```php
  'hostname' => 'db',
  'username' => 'root',
  'password' => '123456',
  ```

## Dockerfile
O `Dockerfile` configura a imagem PHP 7.4 com extensões necessárias e o Composer. Ele também define o diretório de trabalho e expõe a porta 9000 para o servidor PHP embutido.
```dockerfile
FROM php:7.4-cli
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        git curl zip \
        libonig-dev \
        libxml2-dev \
        libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip mysqli pdo_mysql mbstring exif pcntl bcmath opcache soap

RUN pecl install xdebug-2.9.8 \
    && docker-php-ext-enable xdebug

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN usermod -u 1000 www-data

WORKDIR /var/www/html

COPY src/ /var/www/html

EXPOSE 9000

CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]
```
## docker-compose.yml

O docker-compose.yml define dois serviços:

  - app: Serviço PHP que usa a imagem construída a partir do Dockerfile. Expõe a porta 9000 e monta o diretório src/ no contêiner.

  - db: Serviço MariaDB que usa a imagem mariadb:10.6. Expõe a porta 3306 e configura um volume para persistência de dados.

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: php7.4-cli-multas
    ports:
      - "9000:9000"
    volumes:
      - ./src:/var/www/html
    depends_on:
      - db
    environment:
      - DB_HOST=db
      - DB_USER=root
      - DB_PASSWORD=123456
      # - DB_NAME=meu_banco
    networks:
      - php7.4-net

  db:
    image: mariadb:10.6
    container_name: mariadb-multas
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      # MYSQL_DATABASE: meu_banco
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - php7.4-net

volumes:
  db_data:

networks:
  php7.4-net:
    driver: bridge
```

## Como Usar

  1 - Clone o repositório:
  ```bash
  git clone <seu-repositorio>
  cd <seu-repositorio>
  ```
2 - Construa e inicie os containers:
  ```bash
  docker compose up -d
  ```
3 - Acesse a aplicação:  
Abra o navegador e acesse `http://localhost:9000`.

4 - Acesse o banco de dados:
  - Host: `localhost`
  - Porta: `3306`
  - Usuário: `root`
  - Senha: `123456`

5 - Parar os containers:
```bash
docker compose down
```

## Personalização

  - `Banco de Dados`: Para criar um banco de dados específico, descomente as linhas `# MYSQL_DATABASE: meu_banco` no `docker-compose.yml` e `# - DB_NAME=meu_banco` no serviço `app`.

  - `Extensões PHP`: Se precisar de outras extensões PHP, adicione-as ao `Dockerfile` na seção `docker-php-ext-install`.

## Contribuição

Sinta-se à vontade para contribuir com melhorias ou correções. Abra uma issue ou envie um pull request.

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
