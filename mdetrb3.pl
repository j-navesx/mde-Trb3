:- ensure_loaded('golog2_32.pl').

/*--------------------------------------------------*/
/*------------biblioteca de coisas uteis------------*/
/*--------------------------------------------------*/

single_read_numb(Number):-
    read_string(user_input,"\n","\r",_,Str),
    string_to_atom(Str,Atom),
    atom_number(Atom,Number).

/*--------------------------------------------------*/
/*-------------------definições---------------------*/
/*--------------------------------------------------*/

def_all:-
    def_is_a,
    def_factory,
    def_product,
    def_materials,
    def_alarm.

def_is_a:-
    new_relation(is_a, transitive, none, nil). 

def_factory:-
    new_frame(factory),
    new_slot(factory,name),
    new_slot(factory,city),
    new_slot(factory,max_capacity),
    new_slot(factory,total_products_stock),
    new_slot(factory,product_list,[]),
    
    % Metodos
    new_slot(factory,delete_prod_from_list).

def_product:-
    new_frame(product),
    new_slot(product,name),
    new_slot(product,reference),
    new_slot(product,stock_quantity), % Demon - repoe valor min % Demon - corrije total_products_stock
    new_slot(product,stock_log_list,[]), % lista de tuplos (date,amount)
    new_slot(product,material_list,[]), % lista de tuplos (material,amount)
    new_slot(product,price),
    new_slot(product,min_stock),

    % Metodos
    new_slot(product,read_prod_desc),
    new_slot(product,set_prod_desc),
    new_slot(product,delete_prod),
    new_slot(product,encomenda), % Demon - caso não haja stock manda fazer 
    new_slot(product,fabrico). % Demon - caso não haja peças necessárias (generate alarm msg)

def_materials:-
    new_frame(material),
    new_slot(material,name),
    new_slot(material,reference),
    new_slot(material,stock_quantity),

    % Metodos
    new_slot(material,read_material_desc),
    new_slot(material,set_material_desc), 
    new_slot(material,delete_material),
    new_slot(material,request_materials).

def_alarm:- 
    new_frame(alarm),
    new_slot(alarm,event), 
    new_slot(alarm,temp),
    new_slot(alarm,date), 
    new_slot(alarm,count, 0).

genmsg(Time, Event, Date) :- 
    genname(Name), 
    new_frame(Name),
    new_slot(Name,is_a,alarm),
    new_value(Name,event,Event),
    new_value(Name,temp,Time),
    new_value(Name,date,Date).

genname(Name) :- 
    get_value(alarm,count,Count), 
    Count1 is Count+1,
    new_value(alarm,count,Count1),
    atom_concat(alarm,Count1,Name).

/*--------------------------------------------------*/
/*---------------------Metodos----------------------*/
/*--------------------------------------------------*/



/*--------------------------------------------------*/
/*--------------------------------------------------*/
/*--------------------------------------------------*/