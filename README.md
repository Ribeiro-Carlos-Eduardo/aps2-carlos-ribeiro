# APS 2: Dossiê de Arquitetura Viva

## Marketplace B2B de Sobras Industriais

**Aluno:** Carlos Ribeiro  
**Unidade Curricular:** Modelagem de Software  
**Curso:** Engenharia de Software - 4º Período  
**Instituição:** UniSenai  
**Modalidade:** Avaliação Prática Supervisionada - APS 2  
**Tipo de entrega:** Individual  

---

## 1. Funcionalidade crítica selecionada

**Aceite de proposta de sobra industrial, separação da quantidade negociada e retenção do pagamento em custódia por meio de um Gateway de Escrow.**

A funcionalidade começa quando uma empresa compradora seleciona uma oferta e envia uma proposta de negociação.

O Marketplace valida os dados da proposta e verifica a disponibilidade da quantidade solicitada. Quando a proposta é válida, a empresa vendedora pode aceitar ou rejeitar a negociação.

Após o aceite, a quantidade negociada é separada da oferta e uma transação é criada. Em seguida, uma cobrança é solicitada ao Gateway de Escrow.

Se o pagamento for confirmado, a negociação prossegue. Caso o pagamento seja recusado ou expire, a transação é cancelada e a quantidade separada é devolvida para a oferta.

---

## 2. Objetivo da modelagem

Este dossiê documenta a funcionalidade crítica sob cinco perspectivas complementares:

1. interação cronológica entre os participantes;
2. fluxo de atividades e responsabilidades;
3. ciclo de vida da transação;
4. organização arquitetural do sistema;
5. decisão arquitetural relacionada ao pagamento em custódia.

Os modelos são mantidos como código no repositório para permitir versionamento, auditoria e evolução contínua da documentação.

---

## 3. Escopo da funcionalidade

### 3.1 Dentro do escopo

- seleção da oferta;
- envio da proposta;
- validação da proposta;
- verificação da quantidade disponível;
- aceite ou rejeição pela empresa vendedora;
- separação da quantidade negociada;
- criação da transação;
- criação da cobrança no Gateway de Escrow;
- confirmação, recusa ou expiração do pagamento;
- atualização do estado da transação;
- liberação da quantidade em caso de cancelamento;
- envio assíncrono de notificações;
- registro dos eventos para auditoria.

### 3.2 Fora do escopo

- transporte físico das sobras industriais;
- emissão de nota fiscal;
- processamento financeiro interno ao Marketplace;
- armazenamento de dados bancários;
- liberação final dos fundos após a entrega;
- tratamento de disputas comerciais.

---

## 4. Regras de negócio

- **RN01:** Uma negociação somente poderá ser concluída após o aceite de uma proposta válida.
- **RN02:** Uma sobra industrial somente poderá ser negociada enquanto houver quantidade disponível.
- **RN03:** O pagamento somente poderá ser solicitado após a separação da quantidade negociada.
- **RN04:** Uma confirmação de pagamento somente poderá alterar a transação quando sua origem for válida.
- **RN05:** Um pagamento recusado ou expirado deverá cancelar a transação e devolver a quantidade para a oferta.
- **RN06:** Eventos ou cobranças duplicadas deverão ser controlados por meio de idempotência.
- **RN07:** A negociação somente poderá ser confirmada quando os fundos estiverem retidos no Gateway de Escrow.

---

## 5. Participantes e componentes

| Participante ou componente | Responsabilidade |
|---|---|
| Empresa Compradora | Selecionar a oferta, enviar a proposta e realizar o pagamento |
| Empresa Vendedora | Avaliar, aceitar ou rejeitar a proposta |
| Aplicação Web | Disponibilizar a interface do Marketplace |
| Marketplace API | Receber solicitações e coordenar os casos de uso |
| Serviço de Negociação | Aplicar as regras da negociação |
| Serviço de Ofertas | Consultar, separar e liberar quantidades |
| Banco de Dados | Armazenar ofertas, propostas, transações e auditoria |
| Gateway de Escrow | Criar a cobrança e manter o pagamento em custódia |
| Broker de Mensagens | Transportar eventos assíncronos |
| Serviço de Notificações | Notificar empresas compradoras e vendedoras |

---

## 6. Artefato 1: Diagrama de Sequência

O Diagrama de Sequência representa a ordem cronológica das interações necessárias para concluir uma negociação.

O modelo contempla:

- chamadas síncronas;
- comunicação assíncrona;
- retornos utilizando DTOs;
- fragmento combinado `alt/else`;
- repetição através de `loop`;
- fluxo de pagamento confirmado;
- fluxo de pagamento recusado ou expirado.

### Principais participantes

1. Empresa Compradora;
2. Aplicação Web;
3. Marketplace API;
4. Serviço de Negociação;
5. Serviço de Ofertas;
6. Repositório;
7. Empresa Vendedora;
8. Gateway de Escrow;
9. Serviço de Notificações.

### Fluxo principal

```text
Empresa Compradora
        |
        v
Enviar proposta
        |
        v
Marketplace
        |
        v
Validar disponibilidade
        |
        v
Empresa Vendedora
        |
        v
Aceitar proposta
        |
        v
Separar quantidade
        |
        v
Gateway de Escrow
        |
        v
Pagamento
        |
        v
Confirmar negociação
```

### Código-fonte do Diagrama de Sequência

[Consultar sequencia.mmd](docs/diagrams/sequencia.mmd)

---

## 7. Artefato 2: Diagrama de Atividades com Raias

O Diagrama de Atividades representa o fluxo completo da negociação e define as responsabilidades envolvidas no processo.

### Raias utilizadas

1. Empresa Compradora;
2. Marketplace;
3. Empresa Vendedora;
4. Gateway de Escrow;
5. Serviço de Notificações.

### Condições de guarda

Foram consideradas as seguintes condições:

```text
[propostaValida && quantidadeDisponivel]

[!propostaValida || !quantidadeDisponivel]

[fundosConfirmados && dentroDoPrazo]

[pagamentoRecusado || prazoExpirado]
```

### Concorrência

O modelo utiliza estruturas de divisão e sincronização para representar processamento paralelo.

No fluxo de sucesso:

```text
                 FORK
                /    \
               v      v
Atualizar transação   Registrar auditoria
               \      /
                v    v
                 JOIN
                  |
                  v
        Confirmar negociação
```

No fluxo de falha:

```text
               FORK
              /    \
             v      v
Cancelar transação   Liberar quantidade
             \      /
              v    v
               JOIN
                |
                v
       Notificar cancelamento
```

### Código-fonte do Diagrama de Atividades

[Consultar atividades.mmd](docs/diagrams/atividades.mmd)

---

## 8. Artefato 3: Diagrama de Transição de Estados

A entidade principal selecionada para a máquina de estados é a **Transação**.

O ciclo de vida principal da entidade é:

```text
[*]
 |
 v
Criada
 |
 v
EmAnalise
 |
 v
PropostaAceita
 |
 v
SobraSeparada
 |
 v
AguardandoPagamento
 |
 v
FundosRetidos
 |
 v
Confirmada
 |
 v
Concluida
 |
 v
[*]
```

### Estados alternativos

A partir do fluxo principal, a transação também poderá chegar aos seguintes estados:

```text
Cancelada
   |
   v
  [*]
```

ou:

```text
Expirada
   |
   v
  [*]
```

### Subestados de AguardandoPagamento

```text
AguardandoPagamento
        |
        +-- CobrancaCriada
        |
        +-- Conciliando
```

### Exemplo de transição formal

```text
confirmarPagamento
[pagamentoValido]
/
registrarCustodia()
```

A transição contém:

- **Gatilho:** `confirmarPagamento`;
- **Condição de guarda:** `[pagamentoValido]`;
- **Ação de efeito:** `registrarCustodia()`.

### Ações internas

O estado `AguardandoPagamento` utiliza:

```text
entry / iniciarCronometro()

do / monitorarPagamento()

exit / encerrarCronometro()
```

### Código-fonte do Diagrama de Estados

[Consultar estados.mmd](docs/diagrams/estados.mmd)

---

## 9. Artefato 4: Visão Arquitetural C4 Nível 2

A visão C4 Nível 2 representa os principais contêineres do Marketplace e os sistemas externos relacionados à funcionalidade.

### Estrutura arquitetural

```text
Empresa Compradora
        |
      HTTPS
        |
        v
+-------------------+
|   Aplicação Web   |
|       React       |
+-------------------+
        |
    REST/HTTPS
        |
        v
+-------------------+
|  Marketplace API  |
|     Node.js 20    |
+-------------------+
   |        |       |
   |        |       |
 SQL/TCP    |       | REST/HTTPS
   |        |       |
   v        v       v
PostgreSQL RabbitMQ Gateway Escrow
              |
             AMQP
              |
              v
      Worker de Eventos
              |
          REST/HTTPS
              |
              v
   Serviço de Notificações
```

### Contêineres propostos

| Contêiner | Tecnologia | Responsabilidade |
|---|---|---|
| Aplicação Web | React | Interface com compradores e vendedores |
| Marketplace API | Node.js 20 | Regras e coordenação dos casos de uso |
| Banco de Dados | PostgreSQL 16 | Persistência dos dados |
| Broker | RabbitMQ | Mensageria assíncrona |
| Worker de Eventos | Node.js 20 | Processamento dos eventos |

### Sistemas externos

- Gateway de Escrow;
- Serviço de Notificações.

### Protocolos

- HTTPS;
- REST/JSON;
- SQL/TCP;
- Webhook/HTTPS;
- AMQP.

### Models-as-Code

[Consultar workspace.dsl](docs/architecture/workspace.dsl)

> **Observação:** React, Node.js 20, PostgreSQL 16 e RabbitMQ foram adotados como premissas arquiteturais para esta APS. Caso a implementação real utilize tecnologias diferentes, essas tecnologias deverão ser atualizadas no modelo.

---

## 10. Artefato 5: Registro de Decisão Arquitetural - ADR 0001

### Decisão

Utilizar um Gateway de Escrow externo para manter os fundos em custódia durante a negociação.

### Contexto

Comprador e vendedor precisam possuir proteção durante uma negociação B2B.

O vendedor necessita de confirmação financeira antes da continuidade da negociação, enquanto o comprador precisa evitar o pagamento direto sem rastreabilidade.

### Consequências positivas

- redução do risco financeiro;
- separação do processamento financeiro das responsabilidades do Marketplace;
- maior rastreabilidade;
- possibilidade de auditoria;
- controle de cobranças duplicadas;
- melhor separação de responsabilidades.

### Consequências negativas e riscos

- dependência de um sistema externo;
- aumento da complexidade de integração;
- necessidade de tratamento de falhas;
- necessidade de tratar eventos duplicados;
- necessidade de compensação caso o pagamento falhe após a separação da quantidade.

### Documento completo

[Consultar ADR 0001](docs/architecture/adr-0001.md)

---

## 11. DTOs utilizados

Os principais DTOs utilizados na modelagem são:

- `PropostaRequestDTO`;
- `PropostaDTO`;
- `PropostaResponseDTO`;
- `OfertaDTO`;
- `DisponibilidadeDTO`;
- `SeparacaoDTO`;
- `EscrowCriacaoDTO`;
- `EscrowTransacaoDTO`;
- `EscrowConfirmacaoDTO`;
- `EscrowFalhaDTO`;
- `PagamentoInstrucaoDTO`;
- `TransacaoDTO`;
- `ErroNegocioDTO`.

---

## 12. Contratos públicos

| Componente | Operações públicas |
|---|---|
| Marketplace API | `POST /propostas`, `aceitarProposta()`, `webhookPagamentoConfirmado()`, `webhookPagamentoFalhou()` |
| Serviço de Negociação | `criarProposta()`, `aceitarProposta()`, `confirmarPagamento()`, `cancelarTransacao()` |
| Serviço de Ofertas | `consultarDisponibilidade()`, `separarQuantidade()`, `liberarQuantidade()` |
| Repositório | `buscarOfertaPorId()`, `salvarProposta()`, `salvarTransacao()`, `atualizarQuantidade()`, `atualizarStatusotificarPagamento()`, `notificarCancelamento()` |

---

## 13. Matriz de consistência entre os modelos

| Regra ou evento | Sequência | Atividades | Estados | C4 / ADR |
|---|---|---|---|---|
| Validar proposta | `criarProposta()` | Validar proposta | `Criada -> EmAnalise` | Marketplace API |
| Verificar quantidade | `consultarDisponibilidade()` | Decisão de disponibilidade | Guarda `quantidadeDisponivel` | API e Banco |
| Aceitar proposta | `aceitarProposta()` | Avaliação do vendedor | `EmAnalise -> PropostaAceita` | Aplicação Web e API |
| Separar quantidade | `separarQuantidade()` | Separar quantidade | `PropostaAceita -> SobraSeparada` | API e Banco |
| Criar cobrança | `criarCobranca()` | Solicitar custódia | `SobraSeparada -> AguardandoPagamento` | Gateway / ADR |
| Confirmar pagamento | `confirmarPagamento()` | Pagamento confirmado | `AguardandoPagamento -> FundosRetidos` | Webhook |
| Cancelar transação | `cancelarTransacao()` | Fluxo de cancelamento | `Cancelada` | API / ADR |
| Liberar quantidade | `liberarQuantidade()` | Compensação | Ação de cancelamento | API e Banco |
| Notificar participantes | Mensagem assíncrona | Raia de notificações | Ação de efeito | Broker / Worker |

---

## 14. Estrutura do repositório

```text
aps2-carlos-ribeiro/
├── README.md
└── docs/
    ├── architecture/
    │   ├── workspace.dsl
    │   └── adr-0001.md
    └── diagrams/
        ├── sequencia.mmd
        ├── atividades.mmd
        └── estados.mmd
```

---

## 15. Checklist da APS

### Diagrama de Sequência

- [x] desenvolvido como código;
- [x] chamadas síncronas;
- [x] comunicação assíncrona;
- [x] fragmento `alt/else`;
- [x] fragmento `loop`;
- [x] utilização de DTOs;
- [x] tratamento de exceções.

### Diagrama de Atividades

- [x] cinco raias;
- [x] condições de guarda;
- [x] condições mutuamente exclusivas;
- [x] execução paralela;
- [x] Fork;
- [x] Join.

### Máquina de Estados

- [x] estado inicial;
- [x] estados terminais;
- [x] subestados;
- [x] gatilhos;
- [x] condições de guarda;
- [x] ações de efeito;
- [x] `entry`;
- [x] `do`;
- [x] `exit`.

### C4

- [x] visão C4 Nível 2;
- [x] contêineres;
- [x] sistemas externos;
- [x] tecnologias;
- [x] protocolos;
- [x] Models-as-Code.

### ADR e governança

- [x] ADR 0001;
- [x] contexto;
- [x] decisão;
- [x] consequências;
- [x] riscos;
- [x] consistência lógica entre os artefatos;
- [x] evolução registrada por commits.

---

## 16. Considerações finais

A modelagem apresenta diferentes perspectivas da mesma funcionalidade crítica do Marketplace B2B de Sobras Industriais.

O Diagrama de Sequência descreve as interações entre os participantes. O Diagrama de Atividades representa o fluxo e as responsabilidades. A Máquina de Estados controla o ciclo de vida da transação. A visão C4 representa a arquitetura do sistema e a ADR registra a principal decisão técnica.

A utilização de **Diagrams-as-Code** e **Models-as-Code** permite manter a documentação versionada junto ao projeto, facilitando manutenção, auditoria e evolução da arquitetura.
