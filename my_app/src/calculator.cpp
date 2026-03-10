#include <iostream>
#include <string>
#include <vector>
#include <stack>
#include <cmath>
#include <sstream>
#include <iomanip>

extern "C" {
    // Basic evaluation function (to be expanded)
    double evaluate_expression(const char* expression) {
        // Simple implementation for now: only handles basic arithmetic without parentheses
        // A full parser (e.g., Shunting-yard) will be added as we proceed.
        std::string expr(expression);
        if (expr.empty()) return 0.0;

        try {
            // For now, let's just return a placeholder for testing FFI
            // We'll implement the actual scientific logic in the next step.
            return std::stod(expr);
        } catch (...) {
            return 0.0;
        }
    }

    // Example of a scientific function exposed via FFI
    double calculate_sin(double value) {
        return std::sin(value);
    }

    double calculate_cos(double value) {
        return std::cos(value);
    }

    double calculate_tan(double value) {
        return std::tan(value);
    }

    double calculate_sqrt(double value) {
        return std::sqrt(value);
    }
}
