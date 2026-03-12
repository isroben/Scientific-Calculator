#include <iostream>
#include <string>
#include <vector>
#include <stack>
#include <cmath>
#include <algorithm>
#include <map>
#include <sstream>

extern "C" {

// Helper to define operator precedence
int precedence(std::string op) {
    if (op == "+" || op == "-") return 1;
    if (op == "*" || op == "/" || op == "%") return 2;
    if (op == "^") return 3;
    if (op == "sin" || op == "cos" || op == "tan" || op == "log" || op == "ln" || op == "sqrt") return 4;
    return 0;
}

double applyOp(double a, double b, std::string op) {
    if (op == "+") return a + b;
    if (op == "-") return a - b;
    if (op == "*") return a * b;
    if (op == "/") return (b != 0) ? a / b : NAN;
    if (op == "^") return pow(a, b);
    if (op == "%") return fmod(a, b);
    return 0;
}

double applyFunc(double a, std::string func) {
    if (func == "sin") return sin(a);
    if (func == "cos") return cos(a);
    if (func == "tan") return tan(a);
    if (func == "log") return log10(a);
    if (func == "ln") return log(a);
    if (func == "sqrt") return sqrt(a);
    if (func == "abs") return fabs(a);
    return a;
}

__attribute__((visibility("default"))) __attribute__((used))
double evaluate_expression(const char* expression) {
    std::string expr(expression);
    if (expr.empty()) return 0.0;

    std::stack<double> values;
    std::stack<std::string> ops;

    for (int i = 0; i < expr.length(); i++) {
        if (isspace(expr[i])) continue;

        // 1. Handle Numbers (including decimals)
        if (isdigit(expr[i]) || expr[i] == '.') {
            std::string val;
            while (i < expr.length() && (isdigit(expr[i]) || expr[i] == '.')) {
                val += expr[i++];
            }
            values.push(std::stod(val));
            i--;
        }
            // 2. Handle Parentheses
        else if (expr[i] == '(') {
            ops.push("(");
        }
        else if (expr[i] == ')') {
            while (!ops.empty() && ops.top() != "(") {
                std::string op = ops.top(); ops.pop();
                double val2 = values.top(); values.pop();
                double val1 = values.top(); values.pop();
                values.push(applyOp(val1, val2, op));
            }
            if (!ops.empty()) ops.pop(); // Remove '('

            // Check if a function was waiting for this result
            if (!ops.empty() && precedence(ops.top()) == 4) {
                std::string func = ops.top(); ops.pop();
                double val = values.top(); values.pop();
                values.push(applyFunc(val, func));
            }
        }
            // 3. Handle Functions (sin, cos, log, etc.)
        else if (isalpha(expr[i])) {
            std::string func;
            while (i < expr.length() && isalpha(expr[i])) {
                func += expr[i++];
            }
            ops.push(func);
            i--;
        }
            // 4. Handle Operators
        else {
            std::string currentOp(1, expr[i]);
            while (!ops.empty() && precedence(ops.top()) >= precedence(currentOp)) {
                std::string op = ops.top(); ops.pop();
                double val2 = values.top(); values.pop();
                double val1 = values.top(); values.pop();
                values.push(applyOp(val1, val2, op));
            }
            ops.push(currentOp);
        }
    }

    // Final processing
    while (!ops.empty()) {
        std::string op = ops.top(); ops.pop();
        double val2 = values.top(); values.pop();
        double val1 = values.top(); values.pop();
        values.push(applyOp(val1, val2, op));
    }

    return values.empty() ? 0 : values.top();
}
}