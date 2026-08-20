# F1 Moneyball: A Data-Driven Analysis of the Hybrid Era (2014-2024)

*Please scroll down for the Italian version.*

This repository contains the code and data used for my Bachelor's thesis in Economics and Big Data at Università degli Studi Roma Tre. The project investigates how team budgets and operational efficiency shaped Formula 1 standings during the Hybrid Era, with a specific focus on the introduction of the 2021 FIA Cost Cap.

## Research Question
Does a team's budget strictly dictate championship standings, or do operational variables (qualifying pace, race pace, reliability, pit stops) play a more critical role? Furthermore, how did this relationship evolve after the implementation of the budget cap?

## Data Sources
The analysis relies on a relational database built from heterogeneous sources:
* F1 World Championship Dataset (Kaggle): Race results, qualifying, drivers, and constructors from 1950 to 2024.
* DHL Fastest Pit Stop Award: Pit stop points per team and season.
* Financial Data: A dedicated repository containing year-by-year budget estimations cross-referenced from specialized motorsport press (Autosport, Forbes, RaceFans, Motorsport.com). You can find the raw financial sources here: https://github.com/Max-Cattani/f1-budget-hybrid-era .

Note: The raw Kaggle datasets are not redistributed here due to licensing. The `data/` folder contains the derived and aggregated datasets built specifically for this analysis.

## Methodology
The statistical analysis moves from simple explanatory models to predictive and non-linear algorithms:
1. Simple Linear Regression: Baseline verification of the relationship between standings and budget.
2. K-Means Clustering (k=3): Identification of efficiency sub-groups in the pre-cap era to highlight structural heterogeneity.
3. LASSO Regression (with Cross-Validation): Isolation of strictly relevant variables among the predictors, comparing the pre-cap and post-cap eras.
4. Regression Trees: Non-linear modeling to find decision thresholds and validate the previous findings.

## Main Results
Financial power alone is not enough. The budget explains only 27% of the variance in the standings. Adding operational variables drastically improves the model's explanatory power.

The most stable and relevant variables, confirmed by LASSO and Regression Trees, are the mean starting grid position, the delta performance (calculated as starting grid position minus finish position), the number of fastest laps, and pit stop points.

The analysis highlights a "Comeback Paradox". With the introduction of the Cost Cap in 2021, the ability to gain positions during a race and convert them into heavy points remains an almost exclusive privilege of the top teams. This proves that while financial expenditures have been compressed, a latent technical oligarchy still persists.

## Coming Soon
* Python Implementation: A complete porting of the analysis workflow using pandas, scikit-learn, and matplotlib.
* R vs Python Comparison: Evaluating execution times, algorithm stability, and metric variations between the two environments.
* Advanced Robustness Tests: Further validation of the models.

## How to Reproduce
To reproduce the analysis, clone the repository and run the script in your R environment. Ensure the CSV files in the `data/` folder are correctly placed in your working directory.
Required R packages: dplyr, ggplot2, readr, NbClust, tibble, ggrepel, glmnet, tree, mclust.

Credits: 
Author: Massimo Cattani
Academic Supervisor: Prof. Francesco Dotto

---

# F1 Moneyball: Analisi Data-Driven dell'Era Ibrida (2014-2024)

Questa repository contiene il codice e i dati utilizzati per la mia tesi di laurea in Economia e Big Data presso l'Università degli Studi Roma Tre. Il progetto analizza in che modo il budget dei team e l'efficienza operativa abbiano determinato i risultati in Formula 1 durante l'era ibrida, concentrandosi sull'impatto del Cost Cap introdotto dalla FIA nel 2021.

## Domanda di Ricerca
Il budget di un team spiega in modo assoluto i risultati in classifica, o contano di più le variabili operative come la qualifica, il ritmo gara, l'affidabilità e i pit stop? Inoltre, come è mutata questa relazione con l'introduzione del tetto di spesa?

## Fonti Dati
L'analisi si basa su un database relazionale costruito a partire da fonti eterogenee:
* Dataset F1 World Championship (Kaggle): Risultati di gara, qualifiche, piloti e costruttori.
* DHL Fastest Pit Stop Award: Punteggi stagionali per l'efficienza ai box.
* Dati Finanziari: Una repository separata che raccoglie e categorizza le stime di budget incrociate dalla stampa specializzata del settore. È possibile consultare le fonti finanziarie originali qui: https://github.com/Max-Cattani/f1-budget-hybrid-era .

Nota: I dataset grezzi Kaggle non sono inclusi per motivi di licenza. La cartella `data/` contiene i dataset derivati e aggregati, pronti per l'analisi.

## Metodologia
L'analisi statistica passa da modelli esplicativi di base ad algoritmi predittivi e non lineari:
1. Regressione Lineare Semplice: Verifica iniziale della relazione tra punti in classifica e budget.
2. K-Means Clustering (k=3): Individuazione di sotto-gruppi di efficienza nell'era pre-cap per gestire l'eterogeneità strutturale.
3. Regressione LASSO (con Cross-Validation): Selezione delle variabili realmente rilevanti, azzerando il rumore statistico e confrontando i due periodi normativi.
4. Alberi di Regressione: Modello non lineare utilizzato a conferma delle soglie prestazionali individuate.

## Risultati Principali
La disponibilità finanziaria da sola non garantisce la vittoria. Il budget spiega solo il 27% della varianza in classifica. È l'inserimento delle variabili operative a rendere il modello statisticamente solido.

Le variabili più rilevanti, confermate dai modelli di machine learning, sono la posizione media di partenza, il delta performance (ovvero le posizioni recuperate in gara), i giri veloci e i punti ai pit stop.

L'analisi ha fatto emergere il "Paradosso della Rimonta". Nonostante l'introduzione del Cost Cap, la capacità di recuperare posizioni nel traffico e trasformarle in punti pesanti resta una prerogativa quasi esclusiva dei top team. Questo dimostra che il livellamento finanziario non ha cancellato l'oligarchia tecnica preesistente.

## Sviluppi Futuri (Coming Soon)
* Implementazione in Python: Porting completo della pipeline di analisi.
* Confronto Computazionale R vs Python: Valutazione delle metriche, della stabilità degli algoritmi e dei tempi di esecuzione tra i due linguaggi.
* Test di Robustezza: Ulteriore validazione dei modelli applicati.

## Come riprodurre l'analisi
Per riprodurre i risultati, è sufficiente clonare la repository ed eseguire lo script `Script.R`. I dataset necessari si trovano nella cartella `data/`.
Pacchetti R richiesti: dplyr, ggplot2, readr, NbClust, tibble, ggrepel, glmnet, tree, mclust.

Crediti:
Autore: Massimo Cattani
Relatore: Prof. Francesco Dotto
