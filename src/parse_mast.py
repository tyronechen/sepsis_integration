#!/usr/bin/python
# join the extracted tables from mast output
# tables reflect the content of mast.txt
import argparse
import pandas as pd

def main():
    parser = argparse.ArgumentParser(
        description='Take mast len and diagram tables, drop duplicates, join.'
    )
    parser.add_argument('infile_paths', type=str, nargs="+",
                        help='path to mast tables from mast run')
    parser.add_argument('-o', '--outfile_path', type=str, 
                        default="./mast_len_diagram.tsv",
                        help='path to joined tables sorted by e value')

    args = parser.parse_args()
    infile_paths = args.infile_paths
    outfile_path = args.outfile_path
    
    data = [pd.read_csv(i, sep="\t") for i in infile_paths]
    data = data[0].merge(data[1], left_on="SEQUENCE_NAME", right_on="SEQUENCE_NAME", how="outer")
    data.drop(columns=["E-VALUE_y"], inplace=True)
    data.drop_duplicates(inplace=True)
    data.columns = ["SEQUENCE_NAME", "E-VALUE", "LENGTH", "MOTIF_DIAGRAM"]
    data.fillna(value="NA", inplace=True)
    data.to_csv(outfile_path, sep="\t", index=False)

if __name__ == "__main__":
    main()
