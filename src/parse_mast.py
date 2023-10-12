#!/usr/bin/python
# join the extracted tables from mast output
# tables reflect the content of mast.txt
import argparse
import pandas as pd

def main():
    parser = argparse.ArgumentParser(
        description='Take mast tables, join.'
    )
    parser.add_argument('infile_paths', type=str, nargs="+",
                        help='path to mast tables from mast run')
    parser.add_argument('-o', '--outfile_path', type=str, 
                        default="./mast_len_diagram.tsv",
                        help='path to joined tables')

    args = parser.parse_args()
    infile_paths = args.infile_paths
    outfile_path = args.outfile_path
    
    data = [pd.read_csv(i, sep="\t", index_col=0) for i in infile_paths]
    data = data[0].merge(data[1], left_index=True, right_index=True)
    data.drop(columns=["E-VALUE_y"], inplace=True)
    data.drop_duplicates(inplace=True)
    data.columns = ["E-VALUE", "LENGTH", "MOTIF_DIAGRAM"]
    # print(data)
    data.to_csv(outfile_path, sep="\t")

if __name__ == "__main__":
    main()
