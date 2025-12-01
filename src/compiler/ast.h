#ifndef AST_H
#define AST_H

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <memory>
#include <cmath>
#include <algorithm>
#include <iomanip>
#include <ostream>

struct Value;
using ValueList = std::vector<Value>;

// Helpers para geração de código ASM
inline int nextLabelId() {
    static int current = 0;
    return current++;
}

inline std::string escapeString(const std::string& s) {
    std::string out;
    for (char c : s) {
        if (c == '"' || c == '\\') out.push_back('\\');
        out.push_back(c);
    }
    return out;
}

struct Value {
    enum Type { NIL, BOOL, NUMBER, STRING, LIST } type;
    
    bool boolVal;
    double numVal;
    std::string strVal;
    std::shared_ptr<ValueList> listVal;

    Value() : type(NIL), boolVal(false), numVal(0) {}
    Value(bool b) : type(BOOL), boolVal(b), numVal(0) {}
    Value(double n) : type(NUMBER), numVal(n), boolVal(false) {}
    Value(const std::string& s) : type(STRING), strVal(s), numVal(0), boolVal(false) {}
    Value(const char* s) : type(STRING), strVal(s), numVal(0), boolVal(false) {}
    Value(ValueList l) : type(LIST), listVal(std::make_shared<ValueList>(l)), numVal(0), boolVal(false) {}

    std::string toString() const {
        if (type == BOOL) return boolVal ? "Verdadeiro" : "Falso";
        if (type == NUMBER) {
            std::string s = std::to_string(numVal);
            s.erase(s.find_last_not_of('0') + 1, std::string::npos);
            if (!s.empty() && s.back() == '.') s.pop_back();
            return s;
        }
        if (type == STRING) return strVal;
        if (type == LIST) {
            if (!listVal) return "[]";
            std::string res = "[";
            for (size_t i = 0; i < listVal->size(); ++i) {
                res += listVal->at(i).toString();
                if (i < listVal->size() - 1) res += ", ";
            }
            res += "]";
            return res;
        }
        return "Nulo";
    }
};

inline std::map<std::string, Value> globals;

class Node {
public:
    virtual ~Node() = default;
    virtual Value execute() = 0;                 // interpretador
    virtual void generate(std::ostream& out) = 0; // compilador para ASM
};

class Expression : public Node {};

// -------------------- Literais, variáveis e listas --------------------

class Literal : public Expression {
    Value val;
public:
    Literal(Value v) : val(v) {}
    Value execute() override { return val; }

    void generate(std::ostream& out) override {
        switch (val.type) {
        case Value::BOOL:
            out << "PUSH_BOOL " << (val.boolVal ? 1 : 0) << "\n";
            break;
        case Value::NUMBER:
            out << "PUSH_NUM " << std::setprecision(15) << val.numVal << "\n";
            break;
        case Value::STRING:
            out << "PUSH_STR \"" << escapeString(val.strVal) << "\"\n";
            break;
        case Value::LIST:
            out << "; TODO: literal de lista pré-avaliada\n";
            out << "PUSH_NIL\n";
            break;
        case Value::NIL:
        default:
            out << "PUSH_NIL\n";
            break;
        }
    }
};

class Variable : public Expression {
    std::string name;
public:
    Variable(std::string n) : name(n) {}
    Value execute() override {
        if (globals.find(name) == globals.end()) return Value(); 
        return globals[name];
    }

    void generate(std::ostream& out) override {
        out << "LOAD " << name << "\n";
    }
};

class ListAccess : public Expression {
    std::string name;
    Expression* indexExpr;
public:
    ListAccess(std::string n, Expression* idx) : name(n), indexExpr(idx) {}
    Value execute() override {
        Value idxVal = indexExpr->execute();
        if (globals.find(name) != globals.end() && globals[name].type == Value::LIST) {
            int idx = (int)idxVal.numVal;
            auto& list = *globals[name].listVal;
            if (idx >= 0 && idx < (int)list.size()) return list[idx];
        }
        std::cerr << "Erro: Acesso invalido a lista " << name << std::endl;
        return Value();
    }

    void generate(std::ostream& out) override {
        out << "LOAD " << name << "\n";
        indexExpr->generate(out);
        out << "INDEX\n";
    }
};

// -------------------- Operações, funções e listas --------------------

class BinaryOp : public Expression {
    Expression *left, *right;
    std::string op;
public:
    BinaryOp(Expression* l, std::string o, Expression* r) : left(l), op(o), right(r) {}
    Value execute() override {
        Value l = left->execute();
        Value r = right->execute();

        if (op == "+") {
            if (l.type == Value::STRING || r.type == Value::STRING) 
                return Value(l.toString() + r.toString());
            return Value(l.numVal + r.numVal);
        }
        if (op == "-") return Value(l.numVal - r.numVal);
        if (op == "*") return Value(l.numVal * r.numVal);
        if (op == "/") {
            if (r.numVal == 0) return Value(0.0);
            return Value(l.numVal / r.numVal);
        }
        if (op == "%") return Value(std::fmod(l.numVal, r.numVal));
        
        if (op == "==") {
            if (l.type == Value::NUMBER && r.type == Value::NUMBER) 
                return Value(std::abs(l.numVal - r.numVal) < 0.00001);
            return Value(l.toString() == r.toString());
        }
        if (op == "!=") return Value(l.toString() != r.toString());
        if (op == ">") return Value(l.numVal > r.numVal);
        if (op == "<") return Value(l.numVal < r.numVal);
        if (op == ">=") return Value(l.numVal >= r.numVal);
        if (op == "<=") return Value(l.numVal <= r.numVal);
        if (op == "AND") return Value(l.boolVal && r.boolVal);
        if (op == "OR") return Value(l.boolVal || r.boolVal);

        return Value();
    }

    void generate(std::ostream& out) override {
        left->generate(out);
        right->generate(out);

        if (op == "+")        out << "ADD\n";
        else if (op == "-")   out << "SUB\n";
        else if (op == "*")   out << "MUL\n";
        else if (op == "/")   out << "DIV\n";
        else if (op == "%")   out << "MOD\n";
        else if (op == "==")  out << "CMP_EQ\n";
        else if (op == "!=")  out << "CMP_NEQ\n";
        else if (op == "<")   out << "CMP_LT\n";
        else if (op == "<=")  out << "CMP_LTE\n";
        else if (op == ">")   out << "CMP_GT\n";
        else if (op == ">=")  out << "CMP_GTE\n";
        else if (op == "AND") out << "AND\n";
        else if (op == "OR")  out << "OR\n";
        else out << "; operador não suportado: " << op << "\n";
    }
};

class LengthFunc : public Expression {
    Expression* target;
public:
    LengthFunc(Expression* t) : target(t) {}
    Value execute() override {
        Value v = target->execute();
        if (v.type == Value::LIST) return Value((double)v.listVal->size());
        if (v.type == Value::STRING) return Value((double)v.strVal.size());
        return Value(0.0);
    }

    void generate(std::ostream& out) override {
        target->generate(out);
        out << "LEN\n";
    }
};

class ListLiteral : public Expression {
    std::vector<Expression*> elements;
public:
    void add(Expression* e) { elements.push_back(e); }
    Value execute() override {
        ValueList list;
        for (auto e : elements) list.push_back(e->execute());
        return Value(list);
    }

    void generate(std::ostream& out) override {
        for (auto e : elements) {
            e->generate(out);
        }
        out << "BUILD_LIST " << elements.size() << "\n";
    }
};

// -------------------- Estruturas de bloco e statements --------------------

class Block : public Node {
    std::vector<Node*> statements;
public:
    void add(Node* s) { statements.push_back(s); }
    Value execute() override {
        for (auto s : statements) s->execute();
        return Value();
    }

    void generate(std::ostream& out) override {
        for (auto s : statements) {
            s->generate(out);
        }
    }
};

class Assignment : public Node {
    std::string varName;
    Expression* indexExpr; 
    Expression* valueExpr;
    bool isAppend;
public:
    Assignment(std::string name, Expression* val, bool append = false) 
        : varName(name), indexExpr(nullptr), valueExpr(val), isAppend(append) {}
    
    Assignment(std::string name, Expression* idx, Expression* val)
        : varName(name), indexExpr(idx), valueExpr(val), isAppend(false) {}

    Value execute() override {
        Value res = valueExpr->execute();
        
        if (isAppend) {
            if (globals.find(varName) == globals.end()) globals[varName] = Value(ValueList{});
            if (globals[varName].type == Value::LIST) {
                globals[varName].listVal->push_back(res);
            }
        } else if (indexExpr) {
            Value idxVal = indexExpr->execute();
            if (globals[varName].type == Value::LIST) {
                (*globals[varName].listVal)[(int)idxVal.numVal] = res;
            }
        } else {
            globals[varName] = res;
        }
        return res;
    }

    void generate(std::ostream& out) override {
        if (indexExpr) {
            indexExpr->generate(out);   // índice
            valueExpr->generate(out);   // valor
            out << "STORE_INDEX " << varName << "\n";
        } else if (isAppend) {
            valueExpr->generate(out);
            out << "APPEND " << varName << "\n";
        } else {
            valueExpr->generate(out);
            out << "STORE " << varName << "\n";
        }
    }
};

class Question : public Node {
    Expression* expr;
public:
    Question(Expression* e) : expr(e) {}
    Value execute() override {
        std::cout << "[?] " << expr->execute().toString() << std::endl;
        return Value();
    }

    void generate(std::ostream& out) override {
        expr->generate(out);
        out << "QUESTION\n";
    }
};

class Output : public Node {
    Expression* expr;
    std::string prefix;
public:
    Output(std::string p, Expression* e) : prefix(p), expr(e) {}
    Value execute() override {
        std::cout << prefix << " " << expr->execute().toString() << std::endl;
        return Value();
    }

    void generate(std::ostream& out) override {
        expr->generate(out);
        if (prefix == ">>") {
            out << "PRINT\n";
        } else if (prefix == "!") {
            out << "PRINT_CONCL\n";
        } else {
            out << "PRINT\n";
        }
    }
};

class InputAnswer : public Node {
    std::string varName;
public:
    InputAnswer(std::string v) : varName(v) {}
    Value execute() override {
        std::cout << "> ";
        std::string line;
        
        std::cin >> std::ws; 
        
        if (std::getline(std::cin, line)) {
            try {
                size_t pos;
                double d = std::stod(line, &pos);
                if (pos == line.length()) globals[varName] = Value(d);
                else globals[varName] = Value(line);
            } catch (...) {
                if (line == "Verdadeiro" || line == "Sim") globals[varName] = Value(true);
                else if (line == "Falso" || line == "Nao") globals[varName] = Value(false);
                else globals[varName] = Value(line);
            }
        }
        return Value();
    }

    void generate(std::ostream& out) override {
        out << "INPUT " << varName << "\n";
    }
};

class IfStmt : public Node {
    Expression* cond;
    Block* thenBlock;
    Block* elseBlock;
public:
    IfStmt(Expression* c, Block* t, Block* e = nullptr) : cond(c), thenBlock(t), elseBlock(e) {}
    Value execute() override {
        Value c = cond->execute();
        bool isTrue = (c.type == Value::BOOL && c.boolVal) 
                   || (c.type == Value::NUMBER && c.numVal != 0) 
                   || (c.type == Value::STRING && c.strVal == "Sim");
        
        if (isTrue) thenBlock->execute();
        else if (elseBlock) elseBlock->execute();
        return Value();
    }

    void generate(std::ostream& out) override {
        int id = nextLabelId();
        std::string elseLabel = "L_else_" + std::to_string(id);
        std::string endLabel  = "L_end_if_" + std::to_string(id);

        cond->generate(out);
        if (elseBlock) {
            out << "JUMP_IF_FALSE " << elseLabel << "\n";
            thenBlock->generate(out);
            out << "JUMP " << endLabel << "\n";
            out << "LABEL " << elseLabel << "\n";
            elseBlock->generate(out);
            out << "LABEL " << endLabel << "\n";
        } else {
            out << "JUMP_IF_FALSE " << endLabel << "\n";
            thenBlock->generate(out);
            out << "LABEL " << endLabel << "\n";
        }
    }
};

class WhileStmt : public Node {
    Expression* cond;
    Block* block;
public:
    WhileStmt(Expression* c, Block* b) : cond(c), block(b) {}
    Value execute() override {
        while (true) {
            Value c = cond->execute();
            bool isTrue = (c.type == Value::BOOL && c.boolVal) 
                       || (c.type == Value::NUMBER && c.numVal != 0);
            if (!isTrue) break;
            block->execute();
        }
        return Value();
    }

    void generate(std::ostream& out) override {
        int id = nextLabelId();
        std::string startLabel = "L_while_" + std::to_string(id);
        std::string endLabel   = "L_end_while_" + std::to_string(id);

        out << "LABEL " << startLabel << "\n";
        cond->generate(out);
        out << "JUMP_IF_FALSE " << endLabel << "\n";
        block->generate(out);
        out << "JUMP " << startLabel << "\n";
        out << "LABEL " << endLabel << "\n";
    }
};

#endif
