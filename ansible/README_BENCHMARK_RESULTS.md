# How to Check Benchmark Results

## Quick View

Run the results viewer script:

```bash
cd ansible
./view-benchmark-results.sh
```

This will show:
- Summary of all runs
- Performance metrics table
- Output directories
- Speedup analysis
- Quick access commands

## Manual Methods

### 1. View Results Summary

```bash
# SSH to edge node
ssh -i ~/.ssh/spark-cluster-key sparkuser@<EDGE_IP>

# View results file
cat /tmp/benchmark/results.txt
```

### 2. Check Output Directories

Results are stored in separate directories for each executor count:

```bash
# List all output directories
ls -lh /tmp/benchmark/output-*

# View results from 1 executor run
cat /tmp/benchmark/output-1ex/part-* | head -20

# View results from 8 executor run
cat /tmp/benchmark/output-8ex/part-* | head -20

# Count lines in output (number of unique words)
wc -l /tmp/benchmark/output-1ex/part-*
```

### 3. View Detailed Logs

```bash
# List all log files
ls -lh /tmp/benchmark/log-*.txt

# View log for specific executor count
cat /tmp/benchmark/log-1ex.txt
cat /tmp/benchmark/log-2ex.txt
cat /tmp/benchmark/log-4ex.txt
cat /tmp/benchmark/log-8ex.txt
```

### 4. Download Results to Local Machine

```bash
# Download results file
scp -i ~/.ssh/spark-cluster-key \
  sparkuser@<EDGE_IP>:/tmp/benchmark/results.txt \
  ./benchmark-results.txt

# Download all logs
scp -i ~/.ssh/spark-cluster-key \
  sparkuser@<EDGE_IP>:/tmp/benchmark/log-*.txt \
  ./

# Download output from specific run
scp -i ~/.ssh/spark-cluster-key \
  -r sparkuser@<EDGE_IP>:/tmp/benchmark/output-8ex \
  ./output-8-executors
```

## Understanding the Results

### Results File Format

```
=== Spark WordCount Benchmark ===
Start time: Wed Nov 19 04:47:23 UTC 2025
Master: spark://10.0.1.3:7077
Executor Memory: 512m
Input File: /tmp/filesample.txt

Start: Wed Nov 19 04:47:23 UTC 2025
End: Wed Nov 19 04:47:35 UTC 2025
Executors: 1
Status: SUCCESS
Duration: 12 seconds
---
Start: Wed Nov 19 04:47:40 UTC 2025
End: Wed Nov 19 04:47:50 UTC 2025
Executors: 2
Status: SUCCESS
Duration: 10 seconds
---
...
```

### Key Metrics

1. **Duration**: Total execution time in seconds
2. **Status**: SUCCESS or FAILED
3. **Executors**: Number of executors used

### Performance Analysis

Calculate speedup:
```bash
# Speedup = Baseline Time / New Time
# Efficiency = (Speedup / Executors) * 100%

# Example:
# 1 executor: 12 seconds (baseline)
# 2 executors: 10 seconds
# Speedup = 12/10 = 1.2x
# Efficiency = (1.2/2) * 100% = 60%
```

### Expected Results

Good scaling behavior:
- **1→2 executors**: ~1.5-2x speedup (75-100% efficiency)
- **2→4 executors**: ~1.3-1.8x speedup (65-90% efficiency)
- **4→8 executors**: ~1.2-1.5x speedup (30-75% efficiency)

Diminishing returns are normal as you add more executors due to:
- Network overhead
- Shuffle operations
- Task scheduling overhead
- Data locality issues

## Verify Output Correctness

### Check Word Count Output

```bash
# View top 10 most frequent words
cat /tmp/benchmark/output-1ex/part-* | sort -t'(' -k2 -rn | head -10

# Count total unique words
cat /tmp/benchmark/output-1ex/part-* | wc -l

# Verify all runs produce same word count
for dir in /tmp/benchmark/output-*ex; do
  echo "$(basename $dir): $(cat $dir/part-* | wc -l) unique words"
done
```

### Compare Outputs

```bash
# Compare outputs from different executor counts
diff <(sort /tmp/benchmark/output-1ex/part-*) \
     <(sort /tmp/benchmark/output-8ex/part-*)

# Should produce no differences (same results, different execution time)
```

## Troubleshooting

### If results show FAILED status:

1. Check the log file:
   ```bash
   cat /tmp/benchmark/log-<N>ex.txt
   ```

2. Common issues:
   - Memory errors: Increase executor memory
   - File not found: Check file distribution
   - Network errors: Check cluster connectivity

### If outputs are different:

- This shouldn't happen - all runs should produce identical results
- Check for data corruption or race conditions
- Verify input file is the same across all runs

## Next Steps

After reviewing results:

1. **Document findings**: Save results for comparison
2. **Analyze scaling**: Identify optimal executor count
3. **Optimize configuration**: Adjust memory/cores based on results
4. **Run additional tests**: Try different data sizes or configurations

