# APS 2: Dossiê de Arquitetura Viva

## Marketplace B2B de Sobras Industriais

**Aluno:** Carlos Ribeiro  
**Unidade Curricular:** Modelagem de Software  
**Curso:** Engenharia de Software  
**Instituição:** UniSenai  
**Modalidade:** Avaliação Prática Supervisionada, APS 2  
**Tipo de entrega:** Individual  

---

## 1. Funcionalidade crítica selecionada

**Aceite de proposta de sobra industrial, separação da quantidade negociada e retenção do pagamento em custódia por meio de um Gateway de Escrow.**

A funcionalidade começa quando uma empresa compradora seleciona uma oferta e envia uma proposta de negociação.

O Marketplace valida os dados da proposta e verifica se existe quantidade disponível. Quando a proposta é válida, a empresa vendedora é notificada para aceitar ou rejeitar a negociação.

Após o aceite, a quantidade negociada é separada da oferta e uma cobrança é criada em um Gateway de Escrow. O valor permanece em custódia até a confirmação do pagamento.

Se o pagamento for recusado ou expirar, a transação é cancelada e a quantidade separada é devolvida para a oferta.

---

## 2. Objetivo da modelagem

Este dossiê documenta a funcionalidade crítica sob cinco perspectivas:

1. interação cronológica entre os participantes;
2. fluxo de atividades e responsabilidades;
3. ciclo de vida da transação;
4. organização arquitetural do sistema;
5. justificativa de uma decisão arquitetural.

Os modelos são mantidos como código no repositório para permitir versionamento, auditoria e atualização contínua.

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
- liberação da quantidade em caso de falha;
- envio assíncrono de notificações;
- registro dos eventos para auditoria.

### 3.2 Fora do escopo

- transporte físico das sobras industriais;
- emissão de nota fiscal;
- processamento financeiro dentro do Marketplace;
- armazenamento de dados bancários;
- liberação final dos fundos após a entrega;
- tratamento de disputas comerciais.

---

## 4. Regras de negócio

- **RN01:** Uma negociação somente poderá ser concluída após o aceite de uma proposta válida.
- **RN02:** Uma sobra industrial somente poderá ser negociada enquanto houver quantidade disponível.
- **RN03:** O pagamento somente poderá ser solicitado após a separação da quantidade negociada.
- **RN04:** Uma confirmação de pagamento somente poderá alterar a transação quando a assinatura do webhook for válida.
- **RN05:** Um pagamento recusado ou expirado deverá cancelar a transação e devolver a quantidade para a oferta.
- **RN06:** Eventos ou cobranças duplicadas deverão ser identificados por uma chave de idempotência.
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

O Diagrama de Sequência representa a ordem cronológica das interações entre os participantes.

O modelo inclui:

- chamadas síncronas;
- comunicação assíncrona;
- retornos utilizando DTOs;
- fragmentos combinados `alt/else`;
- repetição utilizando `loop`;
- confirmação, recusa e expiração do pagamento.

### Código-fonte

[Consultar o Diagrama de Sequência](docs/diagrams/sequencia.mmd)

---

## 7. Artefato 2: Diagrama de Atividades com Raias

O Diagrama de Atividades representa o fluxo de trabalho da negociação.

As responsabilidades foram separadas nas seguintes raias:

1. Empresa Compradora;
2. Marketplace;
3. Empresa Vendedora;
4. Gateway de Escrow;
5. Serviço de Notificações.

O modelo também apresenta:

- decisões com condições de guarda;
- condições mutuamente exclusivas;
- caminhos de confirmação e cancelamento;
- execução paralela com `Fork`;
- sincronização das tarefas com `Join`.

### Código-fonte

[Consultar o Diagrama de Atividades](docs/diagrams/atividades.mmd)

---

## 8. Artefato 3: Diagrama de Transição de Estados

A entidade principal da máquina de estados é a **Transação**.

O ciclo de vida principal é:

```text
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
```

Também existem os seguintes estados alternativos:

- `Cancelada`;
- `Expirada`.

O estado `AguardandoPagamento` possui:

- subestados;
- ação `entry`;
- ação `do`;
- ação `exit`;
- transições com gatilho;
- condições de guarda;
- ações de efeito.

### Código-fonte

[Consultar o Diagrama de Estados](docs/diagrams/estados.mmd)

---

## 9. Artefato 4: Visão Arquitetural C4 Nível 2

A visão C4 apresenta os contêineres internos do Marketplace e os sistemas externos envolvidos.

### 9.1 Contêineres propostos

- Aplicação Web em React;
- Marketplace API em Node.js 20;
- Worker de Eventos em Node.js 20;
- Banco de Dados PostgreSQL 16;
- Broker de Mensagens RabbitMQ.

### 9.2 Sistemas externos

- Gateway de Escrow;
- Serviço de Notificações.

### 9.3 Protocolos de comunicação

- HTTPS;
- REST/JSON;
- SQL/TCP;
- Webhook/HTTPS;
- AMQP 0-9-1;
- e-mail.

### Código-fonte

[Consultar a Visão C4 Nível 2](docs/architecture/workspace.dsl)

> **Observação:** As tecnologias apresentadas constituem uma proposta arquitetural para esta APS e poderão ser ajustadas conforme a stack efetivamente adotada pelo projeto.

---

## 10. Artefato 5: Registro de Decisão Arquitetural

A ADR 0001 documenta e justifica a utilização de um Gateway de Escrow externo para manter o pagamento em custódia durante a negociação.

A decisão busca:

- reduzir o risco financeiro entre comprador e vendedor;
- separarrmações de pagamento de maneira segura;
- impedir cobranças duplicadas com idempotência.

### Documento

docs/architecture/adr-0001.md

---

## 11. DTOs utilizados

Os seguintes objetos de transferência de dados aparecem na modelagem:

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
| Marketplace API | `POST /propostas`, `aceitarProposta()`, `webhookPagamentoConfirmado()` e `webhookPagamentoFalhou()` |
| Serviço de Negociação | `criarProposta()`, `aceitarProposta()`, `confirmarPagamento()` e `cancelarTransacao()` |
| Serviço de Ofertas | `consultarDisponibilidade()`, `separarQuantidade()` e `liberarQuantidade()` |
| Repositório | `buscarOfertaPorId()`, `salvarProposta()`, `salvarTransacao()`, `atualizarQuantidade()` e `atualizarStatus()` |
| Gateway de Escrow | `criarCobranca()` e `verificarPagamento()` |
| Serviço de Notificações | `notificarNovaProposta()`, `notificarPagamento()` e `notificarCancelamento()` |

---

## 13. Matriz de consistência entre os modelos

| Regra ou evento | Sequência | Atividades | Estados | C4 e ADR |
|---|---|---|---|---|
| Validar proposta | `criarProposta()` | Validar dados | `Criada` para `EmAnalise` | Marketplace API |
| Verificar quantidade | `consultarDisponibilidade()` | Decisão de disponibilidade | Guarda `quantidadeDisponivel` | API e Banco de Dados |
| Aceitar proposta | `aceitarProposta()` | Decisão da empresa vendedora | `EmAnalise` para `PropostaAceita` | Aplicação Web e API |
| Separar quantidade | `separarQuantidade()` | Separar quantidade | `PropostaAceita` para `SobraSeparada` | API e Banco de Dados |
| Criar cobrança | `criarCobranca()` | Gateway cria a cobrança | `SobraSeparada` para `AguardandoPagamento` | Gateway e ADR 0001 |
| Confirmar pagamento | `confirmarPagamento()` | Decisão de pagamento | `AguardandoPagamento` para `FundosRetidos` | Webhook HTTPS |
| Cancelar transação | `cancelarTransacao()` | Fluxo de cancelamento | Estado `Cancelada` | API, Banco de Dados e ADR |
| Liberar quantidade | `liberarQuantidade()` | Ação paralela de compensação | Efeito de cancelamento | API e Banco de Dados |
| Notificar participantes | Mensagem assíncrona | Raia de notificações | Ação de efeito | RabbitMQ e Worker |

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

## 15. Critérios atendidos

- [x] Diagrama de Sequência desenvolvido como código;
- [x] chamadas síncronas;
- [x] comunicação assíncrona;
- [x] fragmentos combinados `alt/else`;
- [x] repetição utilizando `loop`;
- [x] retornos utilizando DTOs;
- [x] Diagrama de Atividades com pelo menos três raias;
- [x] condições de guarda mutuamente exclusivas;
- [x] execução paralela utilizando `Fork` e `Join`;
- [x] máquina de estados com estado inicial;
- [x] máquina de estados com estados terminais;
- [x] utilização de subestados;
- [x] transições com gatilho, guarda e ação;
- [x] ações internas `entry`, `do` e `exit`;
- [x] visão C4 Nível 2;
- [x] tecnologias e protocolos identificados;
- [x] ADR estruturada no formato Nygard;
- [x] consistência lógica entre os cinco artefatos;
- [x] evolução da atividade registrada por commits.

---

## 16. Considerações finais

A modelagem demonstra o comportamento e a arquitetura da funcionalidade de negociação de sobras industriais com pagamento em custódia.

Os artefatos apresentam diferentes perspectivas do mesmo processo e mantêm consistência entre regras de negócio, mensagens, atividades, estados, componentes arquiteturais e decisões técnicas.
