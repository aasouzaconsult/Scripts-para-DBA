Declare @n int, @result float

Select @n = 7,@result=1

Select @result = @result * number 
  From Master..spt_values 
 Where Type='p' 
   And Number Between 1 And @n

Select @result
