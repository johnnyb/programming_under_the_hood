struct person {
	char firstname[40];
	char lastname[40];
	int age;
};

int main()
{	
	volatile struct person p;
	p.age = 333;
}
