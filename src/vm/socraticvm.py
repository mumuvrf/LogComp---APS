#!/usr/bin/env python3
# SocraticVM - Máquina Virtual em Python para a linguagem Maiêutic
#
# Uso:
#   python3 socraticvm.py programa.asm
#   python3 socraticvm.py programa.asm --trace   # mostra o trace das instruções
#
import sys
import time
import math
import random
from dataclasses import dataclass
from typing import List, Dict, Optional


class ValueType:
    NIL = "NIL"
    BOOL = "BOOL"
    NUMBER = "NUMBER"
    STRING = "STRING"
    LIST = "LIST"


@dataclass
class Value:
    type: str = ValueType.NIL
    bool_val: bool = False
    num_val: float = 0.0
    str_val: str = ""
    list_val: Optional[List["Value"]] = None

    @staticmethod
    def nil():
        return Value()

    @staticmethod
    def from_bool(b: bool):
        return Value(type=ValueType.BOOL, bool_val=b)

    @staticmethod
    def from_num(n: float):
        return Value(type=ValueType.NUMBER, num_val=n)

    @staticmethod
    def from_str(s: str):
        return Value(type=ValueType.STRING, str_val=s)

    @staticmethod
    def from_list(l: List["Value"]):
        return Value(type=ValueType.LIST, list_val=list(l))

    def to_string(self) -> str:
        if self.type == ValueType.BOOL:
            return "Verdadeiro" if self.bool_val else "Falso"
        if self.type == ValueType.NUMBER:
            s = f"{self.num_val:.15g}"
            return s
        if self.type == ValueType.STRING:
            return self.str_val
        if self.type == ValueType.LIST:
            if not self.list_val:
                return "[]"
            inner = ", ".join(v.to_string() for v in self.list_val)
            return f"[{inner}]"
        return "Nulo"


@dataclass
class Instruction:
    op: str
    args: List[str]


# Estado da VM
stackVM: List[Value] = []
variables: Dict[str, Value] = {}
labels: Dict[str, int] = {}
reg0: Value = Value.nil()   # registrador 0
reg1: Value = Value.nil()   # registrador 1
start_time: float = 0.0     # para sensor "time"


def trim(s: str) -> str:
    return s.strip()


def parse_string_literal(s: str) -> str:
    """
    Recebe algo como:  "texto \"aspas\""  (com ou sem espaços em volta)
    e devolve:         texto "aspas"
    """
    s = s.strip()
    first = s.find('"')
    last = s.rfind('"')
    if first == -1 or last == -1 or last <= first:
        return s

    inner = s[first + 1:last]
    out = []
    escape = False
    for c in inner:
        if escape:
            out.append(c)
            escape = False
        elif c == "\\":
            escape = True
        else:
            out.append(c)
    return "".join(out)


def load_program(filename: str) -> List[Instruction]:
    program: List[Instruction] = []
    with open(filename, "r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, start=1):
            line = trim(line)
            if not line:
                continue
            if line.startswith(";"):
                continue

            # LABEL só registra endereço
            if line.startswith("LABEL"):
                parts = line.split()
                if len(parts) < 2:
                    print(f"[VM] Erro de sintaxe em LABEL na linha {line_no}")
                    sys.exit(1)
                label_name = parts[1]
                labels[label_name] = len(program)
                continue

            if line.startswith("PUSH_STR"):
                op = "PUSH_STR"
                rest = line[len("PUSH_STR"):].strip()
                program.append(Instruction(op=op, args=[rest]))
            else:
                parts = line.split()
                if not parts:
                    continue
                op = parts[0]
                args = parts[1:]
                program.append(Instruction(op=op, args=args))
    return program


def stack_check(needed: int) -> bool:
    if len(stackVM) < needed:
        print(f"[VM] Erro: pilha com menos de {needed} elementos")
        return False
    return True


def push(v: Value) -> None:
    stackVM.append(v)


def pop() -> Value:
    if not stackVM:
        print("[VM] Erro: pop em pilha vazia")
        return Value.nil()
    return stackVM.pop()


def is_truthy(v: Value) -> bool:
    if v.type == ValueType.BOOL:
        return v.bool_val
    if v.type == ValueType.NUMBER:
        return v.num_val != 0.0
    if v.type == ValueType.STRING:
        return v.str_val != "" and v.str_val not in ("Falso", "Nao")
    if v.type == ValueType.LIST:
        return bool(v.list_val)
    return False


def exec_program(program: List[Instruction], trace: bool = False) -> None:
    global reg0, reg1, start_time

    pc = 0
    n = len(program)
    start_time = time.time()
    rng = random.Random()

    while pc < n:
        ins = program[pc]
        op = ins.op
        args = ins.args

        if trace:
            debug_line = f"[PC={pc}] {op}"
            if args:
                debug_line += " " + " ".join(args)
            print(debug_line, file=sys.stderr)

        if op == "HALT":
            break

        elif op == "PUSH_NUM":
            if not args:
                print("[VM] PUSH_NUM sem argumento")
            else:
                try:
                    v = float(args[0])
                except ValueError:
                    v = 0.0
                push(Value.from_num(v))
            pc += 1

        elif op == "PUSH_BOOL":
            if not args:
                print("[VM] PUSH_BOOL sem argumento")
            else:
                b = bool(int(args[0]))
                push(Value.from_bool(b))
            pc += 1

        elif op == "PUSH_STR":
            if not args:
                print("[VM] PUSH_STR sem argumento")
            else:
                s = parse_string_literal(args[0])
                push(Value.from_str(s))
            pc += 1

        elif op == "PUSH_NIL":
            push(Value.nil())
            pc += 1

        elif op == "LOAD":
            if not args:
                print("[VM] LOAD sem argumento")
            else:
                name = args[0]
                v = variables.get(name, Value.nil())
                push(v)
            pc += 1

        elif op == "STORE":
            if not args:
                print("[VM] STORE sem argumento")
            else:
                if not stack_check(1):
                    return
                v = pop()
                name = args[0]
                variables[name] = v
            pc += 1

        elif op == "APPEND":
            if not args:
                print("[VM] APPEND sem argumento")
            else:
                if not stack_check(1):
                    return
                v = pop()
                name = args[0]
                current = variables.get(name, Value.from_list([]))
                if current.type != ValueType.LIST or current.list_val is None:
                    current = Value.from_list([])
                current.list_val.append(v)
                variables[name] = current
            pc += 1

        elif op == "STORE_INDEX":
            if not args:
                print("[VM] STORE_INDEX sem argumento")
            else:
                if not stack_check(2):
                    return
                val = pop()
                idx_v = pop()
                name = args[0]
                idx = int(idx_v.num_val)
                current = variables.get(name)
                if (
                    current is None or
                    current.type != ValueType.LIST or
                    current.list_val is None
                ):
                    print(f"[VM] STORE_INDEX em variável não-lista: {name}")
                else:
                    if idx < 0 or idx >= len(current.list_val):
                        print("[VM] STORE_INDEX índice fora do intervalo")
                    else:
                        current.list_val[idx] = val
                        variables[name] = current
            pc += 1

        elif op == "INDEX":
            if not stack_check(2):
                return
            idx_v = pop()
            list_v = pop()
            if list_v.type != ValueType.LIST or list_v.list_val is None:
                print("[VM] INDEX aplicado em não-lista")
                push(Value.nil())
            else:
                idx = int(idx_v.num_val)
                if idx < 0 or idx >= len(list_v.list_val):
                    print("[VM] INDEX índice fora do intervalo")
                    push(Value.nil())
                else:
                    push(list_v.list_val[idx])
            pc += 1

        elif op in ("ADD", "SUB", "MUL", "DIV", "MOD"):
            if not stack_check(2):
                return
            b = pop()
            a = pop()
            if op == "ADD":
                if a.type == ValueType.STRING or b.type == ValueType.STRING:
                    push(Value.from_str(a.to_string() + b.to_string()))
                else:
                    push(Value.from_num(a.num_val + b.num_val))
            elif op == "SUB":
                push(Value.from_num(a.num_val - b.num_val))
            elif op == "MUL":
                push(Value.from_num(a.num_val * b.num_val))
            elif op == "DIV":
                if b.num_val == 0.0:
                    print("[VM] Divisão por zero")
                    push(Value.from_num(0.0))
                else:
                    push(Value.from_num(a.num_val / b.num_val))
            elif op == "MOD":
                push(Value.from_num(math.fmod(a.num_val, b.num_val)))
            pc += 1

        elif op in ("CMP_EQ", "CMP_NEQ", "CMP_LT", "CMP_LTE", "CMP_GT", "CMP_GTE"):
            if not stack_check(2):
                return
            b = pop()
            a = pop()
            res = False
            if op == "CMP_EQ":
                if a.type == ValueType.NUMBER and b.type == ValueType.NUMBER:
                    res = abs(a.num_val - b.num_val) < 1e-9
                else:
                    res = a.to_string() == b.to_string()
            elif op == "CMP_NEQ":
                if a.type == ValueType.NUMBER and b.type == ValueType.NUMBER:
                    res = abs(a.num_val - b.num_val) >= 1e-9
                else:
                    res = a.to_string() != b.to_string()
            elif op == "CMP_LT":
                res = a.num_val < b.num_val
            elif op == "CMP_LTE":
                res = a.num_val <= b.num_val
            elif op == "CMP_GT":
                res = a.num_val > b.num_val
            elif op == "CMP_GTE":
                res = a.num_val >= b.num_val
            push(Value.from_bool(res))
            pc += 1

        elif op in ("AND", "OR"):
            if not stack_check(2):
                return
            b = pop()
            a = pop()
            if op == "AND":
                push(Value.from_bool(is_truthy(a) and is_truthy(b)))
            else:
                push(Value.from_bool(is_truthy(a) or is_truthy(b)))
            pc += 1

        elif op == "LEN":
            if not stack_check(1):
                return
            v = pop()
            if v.type == ValueType.LIST and v.list_val is not None:
                size = len(v.list_val)
            elif v.type == ValueType.STRING:
                size = len(v.str_val)
            else:
                size = 0
            push(Value.from_num(float(size)))
            pc += 1

        elif op == "BUILD_LIST":
            if not args:
                print("[VM] BUILD_LIST sem argumento")
                return
            count = int(args[0])
            if not stack_check(count):
                return
            temp: List[Value] = []
            for _ in range(count):
                temp.append(pop())
            temp.reverse()  # preserva a ordem de avaliação
            push(Value.from_list(temp))
            pc += 1

        elif op == "QUESTION":
            if not stack_check(1):
                return
            msg = pop()
            print(f"[?] {msg.to_string()}")
            pc += 1

        elif op == "PRINT":
            if not stack_check(1):
                return
            v = pop()
            print(f">> {v.to_string()}")
            pc += 1

        elif op == "PRINT_CONCL":
            if not stack_check(1):
                return
            v = pop()
            print(f"! {v.to_string()}")
            pc += 1

        elif op == "INPUT":
            if not args:
                print("[VM] INPUT sem argumento")
            else:
                var_name = args[0]
                try:
                    line = input("> ")
                except EOFError:
                    variables[var_name] = Value.nil()
                else:
                    line = line.strip()
                    if line == "":
                        variables[var_name] = Value.nil()
                    else:
                        # tenta número
                        try:
                            num = float(line)
                            # se a string toda é número
                            if str(num) == line or line.replace(",", ".").replace(".", "", 1).isdigit():
                                variables[var_name] = Value.from_num(num)
                            else:
                                variables[var_name] = Value.from_str(line)
                        except Exception:
                            if line in ("Verdadeiro", "Sim"):
                                variables[var_name] = Value.from_bool(True)
                            elif line in ("Falso", "Nao"):
                                variables[var_name] = Value.from_bool(False)
                            else:
                                variables[var_name] = Value.from_str(line)
            pc += 1

        elif op == "JUMP":
            if not args:
                print("[VM] JUMP sem destino")
                return
            label = args[0]
            if label not in labels:
                print(f"[VM] Label não encontrado: {label}")
                return
            pc = labels[label]

        elif op == "JUMP_IF_FALSE":
            if not args:
                print("[VM] JUMP_IF_FALSE sem destino")
                return
            if not stack_check(1):
                return
            cond = pop()
            if not is_truthy(cond):
                label = args[0]
                if label not in labels:
                    print(f"[VM] Label não encontrado: {label}")
                    return
                pc = labels[label]
            else:
                pc += 1

        # Registradores
        elif op == "MOV_TOP_R0":
            if not stack_check(1):
                return
            reg0 = pop()
            pc += 1

        elif op == "MOV_TOP_R1":
            if not stack_check(1):
                return
            reg1 = pop()
            pc += 1

        elif op == "PUSH_R0":
            push(reg0)
            pc += 1

        elif op == "PUSH_R1":
            push(reg1)
            pc += 1

        # Sensores
        elif op == "READ_SENSOR":
            if not args:
                print("[VM] READ_SENSOR sem nome")
            else:
                name = args[0]
                if name == "time":
                    delta = time.time() - start_time
                    push(Value.from_num(delta))
                elif name == "rand":
                    r = random.random()
                    push(Value.from_num(r))
                else:
                    print(f"[VM] Sensor desconhecido: {name}")
                    push(Value.nil())
            pc += 1

        else:
            print(f"[VM] Instrução desconhecida: {op}")
            pc += 1


def main():
    if len(sys.argv) < 2:
        print(f"Uso: {sys.argv[0]} programa.asm [--trace]")
        sys.exit(1)

    filename = sys.argv[1]
    trace = False
    if len(sys.argv) >= 3 and sys.argv[2] == "--trace":
        trace = True

    program = load_program(filename)
    exec_program(program, trace)


if __name__ == "__main__":
    main()
