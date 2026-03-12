#include <jni.h>

// Forward declaration: tells this file the function exists in calculator.cpp
extern "C" double evaluate_expression(const char* expression);

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_example_myapp_NativeTester_evaluate(JNIEnv *env, jobject thiz, jstring expression) {
    const char *nativeString = env->GetStringUTFChars(expression, 0);

    // Call the function from calculator.cpp
    double result = evaluate_expression(nativeString);

    env->ReleaseStringUTFChars(expression, nativeString);
    return result;
}