import serial
import struct

verbose = 1  # Change this to zero to stop dbg_print from printing
dbg_print = print if verbose else lambda *a, **k: None

# replace COM6 with the com for your nexys4 board
serial_port = serial.Serial(port="COM6", baudrate=9600, timeout=10)


def send_reset():
    dbg_print("Sending Reset...")
    dbg_print("number of bytes written: ", serial_port.write(b'\x00'))


def send_id_request():
    dbg_print("Requesting ID...")
    dbg_print("number of bytes written: ", serial_port.write(b'\x02'))
    dbg_print("number of bytes written: ", serial_port.write(b'\x02'))
    dbg_print("number of bytes written: ", serial_port.write(b'\x02'))
    dbg_print("number of bytes written: ", serial_port.write(b'\x02'))
    dbg_print("number of bytes written: ", serial_port.write(b'\x02'))


def send_meta_request():
    dbg_print("Requesting Metadata...")
    dbg_print("number of bytes written: ", serial_port.write(b'\x04'))
    dbg_print("number of bytes written: ", serial_port.write(b'\x04'))
    dbg_print("number of bytes written: ", serial_port.write(b'\x04'))
    dbg_print("number of bytes written: ", serial_port.write(b'\x04'))
    dbg_print("number of bytes written: ", serial_port.write(b'\x04'))


def serial_get_id():
    dbg_print("Waiting for ID response...")
    reverse_ID = []
    for i in range(4):
        reverse_ID.append(serial_port.read())
        dbg_print("byte ", i, " received: ", reverse_ID[-1])
    dbg_print("get ID finished!")
    dbg_print("ID = ", reverse_ID)
    reverse_ID.reverse()
    return reverse_ID


def get_metadata():
    meta_set = {}
    dbg_print("Waiting for metadata response...")
    meta_key = serial_port.read()
    dbg_print("received key ", meta_key, "...")
    while meta_key != b'\x00':
        if meta_key == b'\x00':
            dbg_print("received End of Meta Data")
        elif meta_key == b'\x01':
            dbg_print("received Device Name")
            meta_set["dev_name"] = read_nullterm_str()
        elif meta_key == b'\x02':
            dbg_print("received Version of FPGA firmware")
            meta_set["FPGA_version"] = read_nullterm_str()
        elif meta_key == b'\x03':
            dbg_print("received Ancillary Version (PIC firmware)")
            meta_set["PIC_version"] = read_nullterm_str()
        elif meta_key == b'\x20':
            dbg_print("received Number of Probes")
            meta_set["Probe_cnt"] = read_uint32()
        elif meta_key == b'\x21':
            dbg_print("received Sample memory available (bytes)")
            meta_set["sample_mem_avail"] = read_uint32()
        elif meta_key == b'\x22':
            dbg_print("received Dynamic memory available (bytes)")
            meta_set["dynam_mem_avail"] = read_uint32()
        elif meta_key == b'\x23':
            dbg_print("received Maximum sample rate (Hz)")
            meta_set["max_sample_rate"] = read_uint32()
        elif meta_key == b'\x24':
            dbg_print("received Protocol version")
            meta_set["protocol_version"] = read_uint32()
        elif meta_key == b'\x25':
            dbg_print("received Capability Flags")
            meta_set["Capability_flags"] = read_uint32()
        elif meta_key == b'\x40':
            dbg_print("received Number of Probes (short version)")
            meta_set["Probe_cnt_short"] = read_uint8()
        elif meta_key == b'\x41':
            dbg_print("received Protocol version (short version)")
            meta_set["protocol_version_short"] = read_uint8()
        dbg_print("Waiting for metadata response...")
        meta_key = serial_port.read()
        dbg_print("received key ", meta_key, "...")
    return meta_set


def read_nullterm_str():
    received_char = serial_port.read(1)
    received_str = bytearray()
    while received_char != b'\x00':
        received_str += received_char
        received_char = serial_port.read(1)
    print(struct.pack("b" * len(received_str), *received_str).decode('utf8'))

    return struct.pack("b" * len(received_str), *received_str).decode('utf8')


def read_uint32():
    received_uint32 = bytearray(serial_port.read(4))
    return struct.unpack('>I', received_uint32)[0]


def read_uint8():
    received_uint32 = bytearray(serial_port.read(1))
    return struct.unpack('>B', received_uint32)[0]


dbg_print("Resetting board...")
for _ in range(5):
    send_reset()
send_id_request()
print("board ID: ", serial_get_id())
send_meta_request()
for k, v in get_metadata().items():
    print(k, ": ", v)
