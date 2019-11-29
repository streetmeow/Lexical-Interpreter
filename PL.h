typedef enum varEnum {intType, floatType, voidType, arrayIntType, arrayFloatType} varEnum;

typedef struct Func {
  char* name;
  varEnum returnType;
  varEnum parameter[50];
  int paramCount;
  struct Func* previous;
} func;
