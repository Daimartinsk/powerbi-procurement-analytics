# Power BI — Análise de Execução de Compras Públicas

> **Estudo de caso** · Central de compras pública da saúde (Portugal) · Power BI, DAX, views T-SQL num Lakehouse Fabric, segurança ao nível da linha
>
> 🇬🇧 [English version](README.md)

Dashboards que acompanham quanto do que foi planeado comprar já foi adjudicado, por âmbito, artigo e ano, para uma central de compras que serve vários hospitais. Cada hospital vê apenas os seus dados.

Este repositório cobre a **camada analítica**: as views SQL que preparam os dados para análise, as medidas DAX dos KPIs, o modelo semântico e o desenho de segurança. A plataforma de dados por baixo (OneLake, pipelines, materialização, gateways) está em [fabric-onelake-portfolio](https://github.com/Daimartinsk/fabric-onelake-portfolio).

*Nomes do cliente, entidades, códigos de artigo, nomes de tabelas e valores foram anonimizados. Os números nos exemplos são ilustrativos.*

---

## O que os dashboards respondem

| Página | Pergunta |
|---|---|
| Geral | Quanto foi adjudicado este ano e como compara com o ano anterior? |
| Por âmbito | Que programas de compras estão atrasados na execução? |
| Comparativo | Como evoluiu a execução de ano para ano? |
| Detalhe | Que artigos e processos ainda estão em curso, e quanto falta? |

## Como está construído

1. **Views analíticas** ([`sql/`](sql/)) — consolidam anos, calculam dias úteis entre marcos do processo e preparam KPIs mensais/anuais e comparação com previsões.
2. **Modelo semântico** ([`docs/model.md`](docs/model.md)) — modo Import sobre tabelas materializadas, tabela de medidas dedicada, star schema como alvo.
3. **Medidas DAX** ([`dax/measures.dax`](dax/measures.dax)) — quantidades adjudicadas vs em curso, % de execução por quantidade e por nº de processos, variação ano a ano com coluna de ano inteira, cartão de KPI combinado.
4. **RLS** ([`docs/rls.md`](docs/rls.md)) — um único relatório para todas as entidades; cada uma vê só as suas linhas.

## Decisões analíticas

- **A % de execução dilui quando abrem processos novos.** Mantive a medida como *fotografia do momento*, documentei-a na descrição e acrescentei uma medida complementar, para que uma queda não seja lida como falha. → [`docs/metric-design.md`](docs/metric-design.md)
- **Quantidade vs número de processos.** Um processo grande em curso pode puxar a % por quantidade para baixo mesmo com 9 em 10 processos fechados. As duas leituras aparecem lado a lado.
- **Ano anterior sem coluna de data.** O ano vem como número inteiro, por isso `SAMEPERIODLASTYEAR` falha; a medida usa `ALL` + `MAX(Ano) - 1`.

## Serviços

- Dashboards Power BI do levantamento de requisitos à publicação
- Medidas DAX e desenho de modelos semânticos (Import / Direct Lake, star schema)
- RLS para relatórios multi-entidade
- Views SQL e preparação de dados no Microsoft Fabric

📫 **Contacto:** daianamartinsk@gmail.com · [LinkedIn](https://www.linkedin.com/in/daiana-martins-37b636181)
