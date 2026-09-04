import os

from emulator import main

TEST_PROGRAM_DIR = "test_programs/"

def compile_program(file_name: str, id: str = ""):
    global TEST_PROGRAM_DIR
    os.system(f"./{TEST_PROGRAM_DIR}assemble.sh {TEST_PROGRAM_DIR + file_name}")
    os.system(f"mv a.out {TEST_PROGRAM_DIR}a{id}.out")

def clean():
    os.system(f"rm {TEST_PROGRAM_DIR}/test.elf")
    os.system(f"rm a.out")
    os.system(f"rm {TEST_PROGRAM_DIR}/output.dat")

def read_output() -> str:
    f=open(f"{TEST_PROGRAM_DIR}output.dat", "r")
    content = f.read()
    f.close()
    return content

def run_server():
    import subprocess
    import signal
    import time

    server_process = subprocess.Popen(["python3", "-m", "http.server"])
    time.sleep(1)  # Allow time for the server to start

    def timeout_handler(signum, frame):
        raise TimeoutError("Test timed out")

    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(10)  # Set timeout to 10 seconds

    try:
        yield  # Placeholder if using context manager or additional setup
    except TimeoutError:
        print("Test timed out")
    finally:
        server_process.terminate()
        server_process.wait()
        signal.alarm(0)  # Disable the alarm

def test1():
    # compile_program("test1.s", "1")
    os.system(f"python3 emulator.py {TEST_PROGRAM_DIR}a1.out > {TEST_PROGRAM_DIR}output.dat")
    
    assert read_output() == """hello world

END
"""
    clean()

def test2():
    # compile_program("test2.s", "2")

    os.system(f"python3 emulator.py {TEST_PROGRAM_DIR}a2.out --debug-prints > {TEST_PROGRAM_DIR}output.dat")
    
    assert read_output() == """babbb

END
"""
    clean()

def test3():
    # compile_program("test3.s", "3")

    #os.system(f"python3 -m http.server")
    os.system(f"python3 emulator.py {TEST_PROGRAM_DIR}a3.out > {TEST_PROGRAM_DIR}output.dat")
    
    assert """HTTP/1.0 """ in read_output()
    clean()

""" Hard Drive tests """

def test4():
    from hd_device import VirtHD

    hd = VirtHD()


    assert hd.read_status() == 0

    data1 = b"Hello, Virtual HD! " * 30     # ~550 bytes
    data1 = data1[:512]                     # Fit data to 512 bytes

    try:
        hd.write(data1, device_addr=0)
    except Exception as e:
        assert False

    # Verify that the total size is 512 bytes
    read_data = hd.read(device_addr=0, block_count=1)
    assert 512 == len(read_data)

    # Read the first 50 bytes
    data50 = read_data[:50]
    assert data50 == b'Hello, Virtual HD! Hello, Virtual HD! Hello, Virtu'

    big_data = b"BLOCK1" + b"A" * 506  # Block 1
    big_data += b"BLOCK2" + b"B" * 506  # Block 2  
    big_data += b"BLOCK3" + b"C" * 506  # Block 3
    hd.write(big_data, device_addr=10)

    read_big = hd.read(device_addr=10, block_count=3)
    assert 1536 == len(read_big)
    assert b'BLOCK1' == read_big[0:6]
    assert b'BLOCK2' == read_big[512:518]
    assert b'BLOCK3' == read_big[1024:1030]

    empty_data = hd.read(device_addr=100, block_count=1)
    assert empty_data == b"\x00" * 512

    # Data with incorrect size
    try:
        bad_data = b"This is not 512 bytes"
        hd.write(bad_data, device_addr=50)
        assert False
        return
    except Exception as e:
        assert True

def test5():
    # compile_program("test4.s", "4")
    os.system(f"python3 emulator.py {TEST_PROGRAM_DIR}a4.out > {TEST_PROGRAM_DIR}output.dat")
    
    assert read_output() == """hello world
bye bye


END
"""
    clean()

def test6():
    # compile_program("test5.s", "5")
    os.system(f"python3 emulator.py {TEST_PROGRAM_DIR}a5.out > {TEST_PROGRAM_DIR}output.dat")
    
    assert "HTTP/1.0 200 OK" in read_output()
    assert "Server: SimpleHTTP/" in read_output()
    assert "Content-type:" in read_output()

    clean()

def test8():
    # compile_program("test8.s", "8")
    os.system(f"python3 emulator.py {TEST_PROGRAM_DIR}a8.out --debug-prints > {TEST_PROGRAM_DIR}output.dat")

    assert read_output() == """bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

END
"""
    clean()


def test10():
    # compile_program("test10.s", "10")

    db_path = f"{TEST_PROGRAM_DIR}test10_files.db"
    if os.path.exists(db_path):
        os.remove(db_path)

    os.system(
        f"EMULATOR_FS_DB={db_path} python3 emulator.py {TEST_PROGRAM_DIR}a10.out --debug-prints > {TEST_PROGRAM_DIR}output.dat"
    )

    output = read_output()

    assert "HELLOb" in output
    assert "END" in output

    if os.path.exists(db_path):
        os.remove(db_path)

    clean()

