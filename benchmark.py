#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "pandas",
#     "plotly.express",
#     "kaleido",
#     "tabulate",
#     "numpy",
# ]
# ///

import io
import shutil
import subprocess
import pandas as pd
import numpy as np
import plotly.express as px

if __name__ == "__main__":
    df = pd.read_csv("timings.csv")
    df["elapsed"] = df["elapsed"] / 1_000_000
    df["year"] = df["year"] + 2000
    total_time = df["elapsed"].sum()

    fig = px.sunburst(df, path=["year", "day"], labels="elapsed", values="elapsed")
    fig.update_layout(title_text=f'Total time: {total_time:.0f} ms', title_x=0.5)
    fig.update_traces(insidetextorientation="horizontal")
    fig.update_layout(font=dict(size=12))
    fig.update_traces(texttemplate="%{label:02d}<br>%{value:.2f} ms<br>%{percentParent}")

    fig.write_image("graph.svg")

    df["elapsed"] = df["elapsed"] * 1000
    df = df.pivot(values = "elapsed", index = "day", columns = "year")

    with open("table.md", "w") as file:
        df.to_markdown(file, tablefmt="github", floatfmt=".0f")
