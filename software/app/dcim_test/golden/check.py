import os
import numpy as np


def _compact_bits(s: str) -> str:
    return "".join(s.split())


def _twos_complement_int(bits: str) -> int:
    width = len(bits)
    value = int(bits, 2)
    if bits[0] == "1":
        value -= 1 << width
    return value


def _parse_row_bitstring(row_bits: str, width: int, cols: int, signed: bool) -> np.ndarray:
    expected_len = width * cols
    row_bits = _compact_bits(row_bits)
    if len(row_bits) != expected_len:
        raise ValueError(f"Row length {len(row_bits)} != expected {expected_len} ({width}x{cols})")

    vals = []
    for i in range(cols):
        chunk = row_bits[i * width : (i + 1) * width]
        vals.append(_twos_complement_int(chunk) if signed else int(chunk, 2))
    return np.array(vals, dtype=object)


def transfer_weight(file_name_in, file_name_out=None, wd=4, rows=4, cols=4, sign=0):
    signed = bool(sign)
    lines = []
    with open(file_name_in, "r", encoding="utf-8") as f:
        for line in f:
            bits = _compact_bits(line)
            if bits:
                lines.append(bits)

    if rows == -1:
        num_rows = len(lines)
    else:
        if len(lines) < rows:
            raise ValueError(f"Line count {len(lines)} < rows={rows}")
        if len(lines) > rows:
            lines = lines[:rows]
        num_rows = rows

    matrix = np.zeros((num_rows, cols), dtype=object)
    for r in range(num_rows):
        matrix[r, :] = _parse_row_bitstring(lines[r], wd, cols, signed)

    if file_name_out:
        with open(file_name_out, "w", encoding="utf-8") as fo:
            for r in range(num_rows):
                fo.write(" ".join(str(int(x)) for x in matrix[r, :]) + "\n")
    return matrix


def transfer_act(file_name_in, file_name_out=None, wd1=4, c=1, cols=4, sign=0):
    signed = bool(sign)
    lines = []
    with open(file_name_in, "r", encoding="utf-8") as f:
        for line in f:
            bits = _compact_bits(line)
            if bits:
                lines.append(bits)

    groups = len(lines) // c
    if groups == 0:
        raise ValueError(f"Not enough lines to form one complete group of {c}")
    usable = lines[: groups * c]

    expected_len = cols * wd1
    for idx, row_bits in enumerate(usable):
        if len(row_bits) != expected_len:
            raise ValueError(f"Line {idx} length {len(row_bits)} != expected {expected_len}")

    result = [[0] * cols for _ in range(groups)]
    for g in range(groups):
        group = usable[g * c : (g + 1) * c]
        for k in range(cols):
            chunks = [row[k * wd1 : (k + 1) * wd1] for row in group]
            bits = "".join(chunks)
            result[g][k] = _twos_complement_int(bits) if signed else int(bits, 2)

    matrix = np.array(result, dtype=object)
    if file_name_out:
        with open(file_name_out, "w", encoding="utf-8") as fo:
            for r in range(groups):
                fo.write(" ".join(str(int(x)) for x in matrix[r, :]) + "\n")
    return matrix


def get_config():
    return {
        "type": os.getenv("TYPE", "INT16"),
        "acc": int(os.getenv("ACC", 3)),
        "wd1": int(os.getenv("WD1", 4)),
        "ch_in": int(os.getenv("CH_IN", 64)),
        "ch_out": int(os.getenv("CH_OUT", 64)),
        "r": int(os.getenv("R", 4)),
    }


if __name__ == "__main__":
    cfg = get_config()

    wd1 = cfg["wd1"]
    ch_in = cfg["ch_in"]
    ch_out = cfg["ch_out"]
    r = cfg["r"]
    acc = cfg["acc"]
    sign = cfg["type"] in ["INT4", "INT8", "INT16"]

    if cfg["type"] in ["INT4", "UINT4"]:
        c = 1
    elif cfg["type"] in ["INT8", "UINT8"]:
        c = 2
    elif cfg["type"] in ["INT16", "UINT16"]:
        c = 4
    else:
        raise ValueError(f"Unsupported TYPE={cfg['type']}")

    print(f"Type: {cfg['type']}, Acc: {acc}")

    wd2 = int(2 * wd1 + np.log2(ch_in))
    wd3 = int(wd2 + np.log2(r))

    base = os.path.dirname(__file__)
    weight_mat = transfer_weight(
        os.path.join(base, "wei.mem"),
        os.path.join(base, "weight.txt"),
        wd=wd1 * c,
        rows=ch_in,
        cols=ch_out // c,
        sign=sign,
    )
    act_mat = transfer_act(
        os.path.join(base, "act.mem"),
        os.path.join(base, "activation.txt"),
        wd1=wd1,
        c=c,
        cols=ch_in,
        sign=sign,
    )
    result_mat = transfer_weight(
        os.path.join(base, "res.mem"),
        os.path.join(base, "result.txt"),
        wd=wd3 * c,
        rows=-1,
        cols=ch_out // c,
        sign=sign,
    )

    calculated = act_mat.dot(weight_mat)
    if acc != 0:
        num_rows = calculated.shape[0] // acc
        accumulated = np.zeros((num_rows, calculated.shape[1]), dtype=object)
        for i in range(num_rows):
            accumulated[i, :] = np.sum(calculated[i * acc : (i + 1) * acc, :], axis=0)
        calculated = accumulated

    if np.array_equal(calculated, result_mat):
        print("Result:\n", result_mat)
        print("验证通过")
    else:
        print("Calculated Result:\n", calculated)
        print("Result Matrix from file:\n", result_mat)
        print(f"Shape: calculated {calculated.shape}, file {result_mat.shape}")
        pass_num = 0
        wrong_num = 0
        print("验证失败")
        for rr in range(calculated.shape[0]):
            for cc in range(calculated.shape[1]):
                if calculated[rr, cc] != result_mat[rr, cc]:
                    print(
                        f"Mismatch at ({rr}, {cc}): calculated {calculated[rr, cc]} != file {result_mat[rr, cc]}"
                    )
                    wrong_num += 1
                else:
                    pass_num += 1
        print(f"Passed: {pass_num}, Wrong: {wrong_num}")

