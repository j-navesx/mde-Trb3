:- ensure_loaded('golog2_32.pl').

/*--------------------------------------------------*/
/*------------biblioteca de coisas uteis------------*/
/*--------------------------------------------------*/

conc([], L, L).
conc([C|R], L, [C|T]) :- conc(R, L, T).

single_read_numb(Number):-
    read_string(user_input,"\n","\r",_,Str),
    string_to_atom(Str,Atom),
    atom_number(Atom,Number).

genname(Name) :- 
    get_value(alarm,count,Count), 
    Count1 is Count+1,
    new_value(alarm,count,Count1),
    atom_concat(alarm,Count1,Name).

fail_if_product_exists(Product_name):-
    not(frame_exists(Product_name)),!.
fail_if_product_exists(_):-
    write('The product already exists'),!,fail.

fail_if_material_exists(Material_name):-
    not(frame_exists(Material_name)),!.
fail_if_material_exists(_):-
    write('The material already registered'),!,fail.

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
    new_relation(is_a, transitive, all, nil). 

def_factory:-
    new_frame(factory),
    new_slot(factory,name),
    new_slot(factory,city),
    new_slot(factory,max_capacity),
    new_slot(factory,total_products_stock,0),
    new_slot(factory,product_list),
    
    % Metodos
    new_slot(factory,set_factory_desc,set_factory_desc_F),
    new_slot(factory,add_prod_to_list,add_prod_to_list_F),
    new_slot(factory,delete_prod_from_list,delete_prod_from_list_F).

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
    new_slot(product,create_prod,create_prod_F),
    new_slot(product,read_prod_desc,read_prod_desc_F),
    new_slot(product,set_prod_desc,set_prod_desc_F),
    new_slot(product,delete_prod,delete_prod_F),
    new_slot(product,encomenda), % Demon - caso não haja stock manda fazer 
    new_slot(product,fabrico). % Demon - caso não haja peças necessárias (generate alarm msg)

def_materials:-
    new_frame(material),
    new_slot(material,name),
    new_slot(material,reference),
    new_slot(material,stock_quantity),

    % Metodos
    new_slot(material,create_material,create_material_F),
    new_slot(material,read_material_desc,read_material_desc_F),
    new_slot(material,set_material_desc,set_material_desc_F), 
    new_slot(material,delete_material,delete_material_F),
    new_slot(material,request_materials).

def_alarm:- 
    new_frame(alarm),
    new_slot(alarm,event), 
    new_slot(alarm,time_stamp), 
    new_slot(alarm,count, 0),

    % Metodos
    new_slot(alarm,genmsg,genmsg_F).

/*--------------------------------------------------*/
/*---------------------Metodos----------------------*/
/*--------------------------------------------------*/

/*---------------------factory----------------------*/

set_factory_desc_F(Factory,Name_val,City_val,Max_capacity_val):-
    (nonvar(Name_val)->new_value(Factory,name,Name_val);true),
    (nonvar(City_val)->new_value(Factory,city,City_val);true),
    (nonvar(Max_capacity_val)->new_value(Factory,max_capacity,Max_capacity_val);true).

add_prod_to_list_F(Factory,Product):-
    add_value(Factory,product_list,Product).

delete_prod_from_list_F(Factory,Product):-
    remove_value(Factory,product_list,Product).

/*----------------------alarm-----------------------*/

genmsg_F(_, Event, Time_stamp) :- 
    genname(Name),
    new_frame(Name),
    new_slot(Name,is_a,alarm),
    new_value(Name,event,Event),
    new_value(Name,time_stamp,Time_stamp),
    write('New alarm: '), 
    write(Name), 
    nl.

/*---------------------product----------------------*/

create_prod_F(Product_frame, Product_name):-
    fail_if_product_exists(Product_name),
    new_frame(Product_name),
    new_slot(Product_name,is_a,Product_frame),
    call_method_1(factory,add_prod_to_list,Product_name).

read_prod_desc_F(Product_frame,Name_val,Ref_val,Stock_Quant_val,Stock_log_list_val,Material_list_val,Price_val,Min_stock_val):-
    get_all_slots(product,[_,_,_,_,Material_list,Min_stock,Name,Price,_,Ref,_,Stock_log_list,Stock_Quant]),
    get_value(Product_frame,Name,Name_val),
    get_value(Product_frame,Ref,Ref_val),
    get_value(Product_frame,Stock_Quant,Stock_Quant_val),
    get_value(Product_frame,Stock_log_list,Stock_log_list_val),
    get_value(Product_frame,Material_list,Material_list_val),
    get_value(Product_frame,Price,Price_val),
    get_value(Product_frame,Min_stock,Min_stock_val).

set_prod_desc_F(Product_frame,Name_val,Ref_val,Stock_Quant_val,Stock_log_list_val,Material_list_val,Price_val,Min_stock_val):-
    get_all_slots(product,[_,_,_,_,Material_list,Min_stock,Name,Price,_,Ref,_,Stock_log_list,Stock_Quant]),
    (nonvar(Name_val)->new_value(Product_frame,Name,Name_val);true),
    (nonvar(Ref_val)->new_value(Product_frame,Ref,Ref_val);true),
    (nonvar(Stock_Quant_val)->new_value(Product_frame,Stock_Quant,Stock_Quant_val);true),
    (nonvar(Stock_log_list_val)->new_value(Product_frame,Stock_log_list,Stock_log_list_val);true),
    (nonvar(Material_list_val)->new_value(Product_frame,Material_list,Material_list_val);true),
    (nonvar(Price_val)->new_value(Product_frame,Price,Price_val);true),
    (nonvar(Min_stock_val)->new_value(Product_frame,Min_stock,Min_stock_val);true).

delete_prod_F(Product_frame):-
    delete_frame(Product_frame),
    call_method_1(factory,delete_prod_from_list,Product_frame).

/*--------------------material----------------------*/

create_material_F(Material_frame, Material_name):-
    fail_if_material_exists(Material_name),
    new_frame(Material_name),
    new_slot(Material_name,is_a,Material_frame).

read_material_desc_F(Material_frame,Name_val,Ref_val,Stock_Quant_val):-
    get_all_slots(material,[_,_,Name,_,Ref,_,_,Stock_Quant]),
    get_value(Material_frame,Name,Name_val),
    get_value(Material_frame,Ref,Ref_val),
    get_value(Material_frame,Stock_Quant,Stock_Quant_val).

set_material_desc_F(Material_frame,Name_val,Ref_val,Stock_Quant_val):-
    get_all_slots(material,[_,_,Name,_,Ref,_,_,Stock_Quant]),
    (nonvar(Name_val)->new_value(Material_frame,Name,Name_val);true),
    (nonvar(Ref_val)->new_value(Material_frame,Ref,Ref_val);true),
    (nonvar(Stock_Quant_val)->new_value(Material_frame,Stock_Quant,Stock_Quant_val);true).

delete_material_F(Material_frame):-
    delete_frame(Material_frame).

/*--------------------------------------------------*/
/*--------------------------------------------------*/
/*--------------------------------------------------*/

test_prod(Name_val,Ref_val,Stock_Quant_val,Stock_log_list_val,Material_list_val,Price_val,Min_stock_val):-
    atom_concat(product_,hallo,Product_frame),
    call_method(product,create_prod,[Product_frame]),
    show_frame(Product_frame),
    show_frame(factory),
    call_method(Product_frame,set_prod_desc,[hallo,123,321,[[bla1,23],[bla2,28]],[[p1,23],[p2,28]],23,50]),
    show_frame(Product_frame),
    call_method(Product_frame,read_prod_desc,[Name_val,Ref_val,Stock_Quant_val,Stock_log_list_val,Material_list_val,Price_val,Min_stock_val]),
    write(Name_val),nl,write(Ref_val),nl,write(Stock_Quant_val),nl,write(Stock_log_list_val),nl,write(Material_list_val),nl,write(Price_val),nl,write(Min_stock_val),nl,
    call_method_0(Product_frame,delete_prod),
    show_frame(factory),
    show_frame(Product_frame).

test_mat(Name_val,Ref_val,Stock_Quant_val):-
    atom_concat(material_,hallo,Material_frame),
    call_method(material,create_material,[Material_frame]),
    show_frame(Material_frame),
    call_method(Material_frame,set_material_desc,[hallo,123,321]),
    show_frame(Material_frame),
    call_method(Material_frame,read_material_desc,[Name_val,Ref_val,Stock_Quant_val]),
    write(Name_val),nl,write(Ref_val),nl,write(Stock_Quant_val),nl,
    call_method_0(Material_frame,delete_material),
    show_frame(Material_frame).
    
get(Name,Ref,Stock_Quant):-
    get_all_slots(material,[_,Name,_,Ref,_,_,Stock_Quant]).