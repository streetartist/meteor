import subprocess
import time
import sys

def run_with_timer(exe_path, name, input_data=None):
    """Run an executable and measure its time."""
    print(f"\n{'='*50}")
    print(f"Running: {name}")
    print(f"Executable: {exe_path}")
    print(f"{'='*50}")
    
    start = time.perf_counter()
    try:
        result = subprocess.run(
            [exe_path],
            input=input_data,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        end = time.perf_counter()
        elapsed = end - start
        
        # Get output length to verify correctness
        output_lines = result.stdout.strip().splitlines()
        # Find the fibonacci result (longest line with digits)
        fib_result = ""
        for line in output_lines:
            if line.isdigit() and len(line) > len(fib_result):
                fib_result = line
        
        print(f"Time: {elapsed:.3f} seconds")
        print(f"Output digits: {len(fib_result)}")
        print(f"First 20 digits: {fib_result[:20]}...")
        print(f"Last 20 digits: ...{fib_result[-20:]}")
        
        return elapsed, len(fib_result)
    except subprocess.TimeoutExpired:
        print(f"TIMEOUT after 300 seconds!")
        return None, 0
    except Exception as e:
        print(f"Error: {e}")
        return None, 0

def main():
    print("="*60)
    print("   Fibonacci Speed Benchmark: Meteor vs C")
    print("="*60)
    
    # C version has n = 1000000 hardcoded
    # Meteor version reads from input
    n = 1000000
    
    # Run C version
    c_time, c_len = run_with_timer("tests/c/fib_fast.exe", f"C Version (n={n})")
    
    # Run Meteor version (needs input)
    met_time, met_len = run_with_timer("tests/meteor/fib_fast.exe", f"Meteor Version (n={n})", f"{n}\n")
    
    # Summary
    print("\n" + "="*60)
    print("   SUMMARY")
    print("="*60)
    
    if c_time and met_time:
        print(f"C Version:      {c_time:.3f}s  ({c_len} digits)")
        print(f"Meteor Version: {met_time:.3f}s  ({met_len} digits)")
        
        if c_time < met_time:
            ratio = met_time / c_time
            print(f"\n>>> C is {ratio:.2f}x faster than Meteor")
        else:
            ratio = c_time / met_time
            print(f"\n>>> Meteor is {ratio:.2f}x faster than C")
    else:
        print("Benchmark incomplete due to errors.")

if __name__ == "__main__":
    main()
