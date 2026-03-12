#include <string>
#include <cmath>

// Your future Shunting-Yard parser will go here
double parseAndEvaluate(const std::string& expr) {
    // For now, let's just return a dummy value so we can test the bridge
    return 42.0; 
}

// The C-Bridge that Dart will talk to
extern "C" {
    // __attribute__ forces the compiler to keep this function visible
    __attribute__((visibility("default"))) __attribute__((used))
    double evaluate_expression(const char* expression) {
        // Convert the C-style string to a C++ std::string
        std::string expr(expression);
        
        // Run your complex logic
        return parseAndEvaluate(expr);
    }
}