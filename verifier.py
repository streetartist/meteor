import sys
import subprocess
import os

# Increase integer string conversion limit for huge numbers
sys.set_int_max_str_digits(0)

def get_fib_python(n):
    if n == 0: return 0
    if n == 1: return 1
    a, b = 0, 1
    # Fast doubling in python or just simple loop? 1M loop is fast enough in C, python maybe slow?
    # Python's loop for 1M is a bit slow (O(N^2) bigint mul).
    # Let's use fast doubling logic in Python for speed.
    
    def _fib(n):
        if n == 0: return (0, 1)
        else:
            a, b = _fib(n // 2)
            c = a * (b * 2 - a)
            d = a * a + b * b
            if n % 2 == 0:
                return (c, d)
            else:
                return (d, c + d)
    
    return _fib(n)[0]

def run_c_version():
    try:
        # C version has hardcoded 1000000
        result = subprocess.run(["tests/c/fib_fast.exe"], capture_output=True, text=True, timeout=30)
        output = result.stdout
        # Output format:
        # Enter n ...
        # Fibonacci result:
        # <NUMBER>
        lines = output.strip().splitlines()
        # Find the line that looks like a digit string
        for line in lines:
            if line.isdigit() and len(line) > 100:
                return line.strip()
            # If base 10^19 print optimization is used, it might be correctly formatted as one line
        # Fallback: check last line
        if lines[-1].isdigit():
            return lines[-1].strip()
        return None
    except Exception as e:
        print(f"C execution failed: {e}")
        return None

def run_meteor_version(n):
    try:
        # Meteor version needs input
        result = subprocess.run(["tests/meteor/fib_fast.exe"], input=f"{n}\n", capture_output=True, text=True, timeout=60)
        output = result.stdout
        lines = output.strip().splitlines()
        for line in lines:
            if line.isdigit() and len(line) > 100:
                return line.strip()
        if lines[-1].isdigit():
            return lines[-1].strip()
        return None
    except Exception as e:
        print(f"Meteor execution failed: {e}")
        return None

def main():
    n = 1000000
    print(f"Calculating Fib({n}) in Python (Ground Truth)...")
    truth = get_fib_python(n)
    truth_str = str(truth)
    print(f"Ground Truth Length: {len(truth_str)}")
    print(f"Ground Truth Start: {truth_str[:20]}...")
    print(f"Ground Truth End:   ...{truth_str[-20:]}")
    
    print("\nRunning C Version...")
    c_out = run_c_version()
    if c_out:
        print(f"C Output Length: {len(c_out)}")
        print(f"C Output Start: {c_out[:20]}...")
        print(f"C Output End:   ...{c_out[-20:]}")
        if c_out == truth_str:
            print(">>> C Version is CORRECT")
        else:
            print(">>> C Version is INCORRECT")
            # Analyze diff
            if len(c_out) != len(truth_str):
                print(f"    Length mismatch: C={len(c_out)}, Truth={len(truth_str)}")
            else:
                 print("    Length matches, content differs.")
    else:
        print("C Version produced no valid output.")

    print("\nRunning Meteor Version...")
    met_out = run_meteor_version(n)
    if met_out:
        print(f"Met Output Length: {len(met_out)}")
        print(f"Met Output Start: {met_out[:20]}...")
        print(f"Met Output End:   ...{met_out[-20:]}")
        if met_out == truth_str:
            print(">>> Meteor Version is CORRECT")
        else:
            print(">>> Meteor Version is INCORRECT")
            if len(met_out) != len(truth_str):
                print(f"    Length mismatch: Met={len(met_out)}, Truth={len(truth_str)}")
            else:
                 print("    Length matches, content differs.")
    else:
        print("Meteor Version produced no valid output.")

if __name__ == "__main__":
    main()
