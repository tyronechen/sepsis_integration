#!/usr/bin/python
import argparse
import os
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from tqdm import tqdm

def extract(data, condition, count):
    """Take out the columns of interest and reformat"""
    pattern = "".join([condition, "_replicate_", str(count)])
    cols = data.filter(regex=pattern).columns.tolist()
    cols.append("entity_id")
    subset = data[cols]
    sample_name = subset[cols].iloc[:, 0].unique()[0]
    subset = subset.iloc[:, 1:].T.reset_index().drop("index", axis=1)
    subset.columns = subset.iloc[1].tolist()
    subset.drop(1, inplace=True)
    subset.index = [sample_name]
    return subset

def main():
    parser = argparse.ArgumentParser(
     description='Extract multi-omics data from BPA Sepsis master tables'
    )
    parser.add_argument('infile_path', type=str,
                        help='path to infile.tsv file to load data from')
    parser.add_argument('-sp', '--species', type=str, default=None,
                        help='what attributes to pull out of the data')
    parser.add_argument('-st', '--strain', type=str, default=None,
                        help='what attributes to pull out of the data')
    parser.add_argument('-om', '--omics', type=str, default=None,
                        help='what attributes to pull out of the data')
    parser.add_argument('-o', '--outfile_dir', type=str, default="./out",
                        help='path to output dir')

    args = parser.parse_args()
    infile_path = args.infile_path
    species = args.species
    strain = args.strain
    omics = args.omics
    outfile_dir = args.outfile_dir

    if outfile_dir == "./out":
        print("No output_dir provided, default to:", outfile_dir)
    if not os.path.isdir(outfile_dir):
        os.makedirs(outfile_dir)

    data = pd.read_csv(infile_path, sep="\t", low_memory=False)
    data = data[
        (data.Species == species) &
        (data.Strain == strain) &
        (data.Type_of_Experiment == omics)
    ]
    data.drop(
        ["Species", "Strain", "Type_of_Experiment", "Units"],axis=1,inplace=True
        )

    # entity_id and additional_id have the molecule name and/or annotations
    patterns = "|".join([
        "entity_id",
        "additional_id",
        "replicate_name_RPMI_replicate_",
        "replicate_name_Sera_replicate_",
        "Log_Counts_",
        # "Imputed_RPMI_replicate_",
        # "Imputed_Sera_replicate_"
        ])
    data = data.filter(regex=patterns)
    names = data.filter(regex="replicate_name_").columns.tolist()
    data[names] = data[names].astype(int, errors="ignore")
    data.dropna(axis=1, how="all", inplace=True)

    samples = [[
        extract(data, c, i) for i in tqdm(range(1, 7), desc="Parsing condition")
        ] for c in ["RPMI", "Sera"]]
    samples = pd.concat([i for j in samples for i in j], axis=0)
    samples = samples.apply(pd.to_numeric)

    print("Null value count:\n", samples.T.isna().sum())
    samples = samples.apply(lambda x: x.fillna(x.median()), axis=1)

    fig = samples.T.boxplot()
    fig.set_xticklabels(fig.get_xticklabels(), rotation=45)
    plt.title(" ".join([species, strain, omics]))
    plt.savefig("".join([outfile_dir, "/", strain, "_box.pdf"]))
    plt.close()

    fig = sns.violinplot(data=samples.T)
    fig.set_xticklabels(fig.get_xticklabels(), rotation=45)
    plt.title(" ".join([species, strain, omics]))
    plt.savefig("".join([outfile_dir, "/", strain, "_violin.pdf"]))
    plt.close()
    samples.to_csv("".join([outfile_dir, "/", strain, ".tsv"]), sep="\t")

if __name__ == "__main__":
    main()
