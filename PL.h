typedef enum varEnum {intType, floatType, voidType, arrayIntType, arrayFloatType} varEnum;

typedef struct Func {
  char* name;
  varEnum returnType;
  varEnum parameter[50];
  int paramCount;
  struct Func* previous;
} func;

typedef struct Var { 
	varEnum type;
	char* name;
	int setCount; 
	int scopeLevel;
	func* masterFunc;
	struct Var* previous;
	struct Var* next;
	union {
		int int_value;
		double float_value;
	};
} var;