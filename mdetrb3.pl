:- ensure_loaded('golog2_32.pl').

/*--------------------------------------------------*/
/*------------biblioteca de coisas uteis------------*/
/*--------------------------------------------------*/

conc([], L, L).
conc([C|R], L, [C|T]) :- conc(R, L, T).

member(E,[E|_]).
member(E,[_|R]) :- member(E,R).

press_any_key(_):-
    write('Press any key: '),
    get_single_char(_),
    nl.

single_read_numb(Number):-
    read_string(user_input,"\n","\r",_,Str),
    string_to_atom(Str,Atom),
    atom_number(Atom,Number).

single_read_option_1(Op):-
    write('-> '),
    read_string(user_input,"\n","\r",_,Str),
    string_to_atom(Str,Atom),
    atom_number(Atom,Op),
    (Op >= 1, Op =< 9),!.
single_read_option_1(Op):-
    single_read_option_1(Op).

single_read_option_2(Op):-
    write('-> '),
    read_string(user_input,"\n","\r",_,Str),
    string_to_atom(Str,Atom),
    atom_number(Atom,Op),
    (Op >= 1, Op =< 8),!.
single_read_option_2(Op):-
    single_read_option_2(Op).

single_read_option_3(Op):-
    write('-> '),
    read_string(user_input,"\n","\r",_,Str),
    string_to_atom(Str,Atom),
    atom_number(Atom,Op),
    (Op >= 1, Op =< 5),!.
single_read_option_3(Op):-
    single_read_option_3(Op).

single_read_string(Atom):-
    read_string(user_input,"\n","\r",_,Str),
    string_to_atom(Str,Atom).

genname(Name) :- 
    get_value(alarm,count,Count), 
    Count1 is Count+1,
    new_value(alarm,count,Count1),
    atom_concat(alarm,Count1,Name).

fail_if_product_exists(Product_name):-
    not(frame_exists(Product_name)),!.
fail_if_product_exists(_):-
    write('The product already exists'),nl,!,fail.

fail_if_material_exists(Material_name):-
    not(frame_exists(Material_name)),!.
fail_if_material_exists(_):-
    write('The material already registered'),nl,!,fail.

if_material_exists(Material_name):-
    frame_exists(Material_name),!.
if_material_exists(_):-
    write('Material not registered'),nl,!,fail.

if_material_exists_in_list(Material_name,[[Material_name,_]|_]).
if_material_exists_in_list(Material_name,[_|Rest]):-
    if_material_exists_in_list(Material_name,Rest).

/*--------------------------------------------------*/
/*-------------------DEFINITION---------------------*/
/*--------------------------------------------------*/

def_all:-
    def_is_a,
    def_factory,
    def_product,
    def_materials,
    def_alarm,
    def_test.

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
    new_slot(factory,delete_prod_from_list,delete_prod_from_list_F),
    new_slot(factory,read_factory_desc,read_fact_desc_F).

def_product:-
    new_frame(product),
    new_slot(product,name),
    new_slot(product,reference),
    new_slot(product,stock_quantity,0), % Demon - repoe valor min % Demon - corrije total_products_stock
    new_slot(product,stock_log_list,[]), % lista de tuplos (date,amount)
    new_slot(product,material_list,[]), % lista de tuplos (material,amount)
    new_slot(product,price),
    new_slot(product,min_stock),
    new_slot(product,numb_requests,0),

    % Metodos
    new_slot(product,create_prod,create_prod_F),
    new_slot(product,read_prod_desc,read_prod_desc_F),
    new_slot(product,set_prod_desc,set_prod_desc_F),
    new_slot(product,delete_prod,delete_prod_F),
    new_slot(product,encomenda,encomenda_F), % Demon - caso não haja stock manda fazer 
    new_slot(product,fabrico,fabrico_F), % Demon - caso não haja peças necessárias (generate alarm msg)

    % Demons
    new_demon(product,stock_quantity,min_stock_Demon,if_write,after,side_effect),
    add_demon(product,stock_quantity,total_products_stock_Demon,if_write,before,side_effect),
    new_demon(product,encomenda,encomenda_D,if_execute,before,side_effect),
    new_demon(product,fabrico,fabrico_D,if_execute,before,side_effect).

def_materials:-
    new_frame(material),
    new_slot(material,name),
    new_slot(material,reference),
    new_slot(material,stock_quantity),
    new_slot(material,product_list),

    % Metodos
    new_slot(material,create_material,create_material_F),
    new_slot(material,read_material_desc,read_material_desc_F),
    new_slot(material,set_material_desc,set_material_desc_F), 
    new_slot(material,delete_material,delete_material_F),
    new_slot(material,add_product_material,add_product_material_F),
    new_slot(material,rmv_product_material,rmv_product_material_F).

def_alarm:- 
    new_frame(alarm),
    new_slot(alarm,event), 
    new_slot(alarm,time_stamp), 
    new_slot(alarm,count, 0),

    % Metodos
    new_slot(alarm,genmsg,genmsg_F),
    new_slot(alarm,read_alarm_desc,read_alarm_desc_F).

/*--------------------------------------------------*/
/*---------------------METHODS----------------------*/
/*--------------------------------------------------*/

/*---------------------FACTORY----------------------*/

set_factory_desc_F(Factory,Name_val,City_val,Max_capacity_val,Total_products_stock):-
    (nonvar(Name_val)->new_value(Factory,name,Name_val);true),
    (nonvar(City_val)->new_value(Factory,city,City_val);true),
    (nonvar(Max_capacity_val)->new_value(Factory,max_capacity,Max_capacity_val);true),
    (nonvar(Total_products_stock)->new_value(Factory,total_products_stock,Total_products_stock);true).

add_prod_to_list_F(Factory,Product):-
    add_value(Factory,product_list,Product).

read_fact_desc_F(Factory,Name_val,City_val,Max_capacity_val,Total_Stock_val,Product_list_val):-
    get_value(Factory,name,Name_val),
    get_value(Factory,city,City_val),
    get_value(Factory,max_capacity,Max_capacity_val),
    get_value(Factory,total_products_stock,Total_Stock_val),
    get_values(Factory,product_list,Product_list_val).

delete_prod_from_list_F(Factory,Product):-
    remove_value(Factory,product_list,Product).

/*----------------------ALARM-----------------------*/

genmsg_F(_, Event, Time_stamp) :- 
    genname(Name),
    new_frame(Name),
    new_slot(Name,is_a,alarm),
    new_value(Name,event,Event),
    new_value(Name,time_stamp,Time_stamp),
    write('New alarm: '), 
    write(Name), 
    nl.

read_alarm_desc_F(Alarm, Event_val, Time_val, Count_val):-
    get_value(Alarm,event,Event_val),
    get_value(Alarm,time_stamp,Time_val),
    get_value(Alarm,count,Count_val).

/*---------------------PRODUCT----------------------*/

create_prod_F(Product_frame, Product_name):-
    fail_if_product_exists(Product_name),
    new_frame(Product_name),
    new_slot(Product_name,is_a,Product_frame),
    call_method_1(factory,add_prod_to_list,Product_name),
    write('Product created'),nl.

read_prod_desc_F(Product_frame,Name_val,Ref_val,Stock_Quant_val,Stock_log_list_val,Material_list_val,Price_val,Min_stock_val,Numb_requests_val):-
    get_value(Product_frame,name,Name_val),
    get_value(Product_frame,reference,Ref_val),
    get_value(Product_frame,stock_quantity,Stock_Quant_val),
    get_value(Product_frame,stock_log_list,Stock_log_list_val),
    get_value(Product_frame,material_list,Material_list_val),
    get_value(Product_frame,price,Price_val),
    get_value(Product_frame,min_stock,Min_stock_val),
    get_value(Product_frame,numb_requests,Numb_requests_val).

set_prod_desc_F(Product_frame,Name_val,Ref_val,Stock_Quant_val,Stock_log_list_val,Material_list_val,Price_val,Min_stock_val):-
    (nonvar(Name_val)->new_value(Product_frame,name,Name_val);true),
    (nonvar(Ref_val)->new_value(Product_frame,reference,Ref_val);true),
    (nonvar(Stock_Quant_val)->new_value(Product_frame,stock_quantity,Stock_Quant_val);true),
    (nonvar(Stock_log_list_val)->new_value(Product_frame,stock_log_list,Stock_log_list_val);true),
    (nonvar(Material_list_val)->new_value(Product_frame,material_list,Material_list_val);true),
    (nonvar(Price_val)->new_value(Product_frame,price,Price_val);true),
    (nonvar(Min_stock_val)->new_value(Product_frame,min_stock,Min_stock_val);true).

delete_prod_F(Product_frame):-
    delete_frame(Product_frame),
    call_method_1(factory,delete_prod_from_list,Product_frame).

encomenda_F(Product,Amount):-
    %Retirar amount aos logs
    get_value(Product,stock_log_list,Stock_log_list),
    rmv_stock_from_logs(Stock_log_list,Amount,New_stock_log_list),
    new_value(Product,stock_log_list,New_stock_log_list),
    %Retirar amount ao total
    get_value(Product,stock_quantity,Stock_quantity),
    New_Stock_quantity is Stock_quantity - Amount,
    new_value(Product,stock_quantity,New_Stock_quantity),
    format('~w ~w encomendados ~n',[Amount,Product]).

%call_method(product1,encomenda,[14]).

rmv_stock_from_logs(Stock_log_list,0,Stock_log_list).
rmv_stock_from_logs([[_,Stock]|Rest],Amount,New_stock_log_list):-
    (Stock =< Amount),
    New_amount is Amount - Stock,
    rmv_stock_from_logs(Rest,New_amount,New_stock_log_list),!.
rmv_stock_from_logs([[Date,Stock]|Rest],Amount,[[Date,New_stock]|Rest]):-
    (Stock > Amount),
    New_stock is Stock - Amount,!.

fabrico_F(Product,Amount):-
    get_value(Product,stock_log_list,Stock_log_list),
    date(Date),
    conc([Date],[Amount],Stock_log),
    conc(Stock_log_list,[Stock_log],New_Stock_log_list),
    new_value(Product,stock_log_list,New_Stock_log_list),
    get_value(Product,stock_quantity,Stock_quantity),
    New_Stock_quantity is Stock_quantity + Amount,
    new_value(Product,stock_quantity,New_Stock_quantity),
    format('~w ~w produzidos ~n',[Amount,Product]).

%call_method(product1,fabrico,[10]).

/*--------------------MATERIAL----------------------*/

create_material_F(Material_frame, Material_name):-
    fail_if_material_exists(Material_name),
    new_frame(Material_name),
    new_slot(Material_name,is_a,Material_frame),
    write('Material created'),nl.

read_material_desc_F(Material_frame,Name_val,Ref_val,Stock_Quant_val,Product_list_val):-
    get_value(Material_frame,name,Name_val),
    get_value(Material_frame,reference,Ref_val),
    get_value(Material_frame,stock_quantity,Stock_Quant_val),
    get_values(Material_frame,product_list,Product_list_val).

set_material_desc_F(Material_frame,Name_val,Ref_val,Stock_Quant_val,Product_list_val):-
    (nonvar(Name_val)->new_value(Material_frame,name,Name_val);true),
    (nonvar(Ref_val)->new_value(Material_frame,reference,Ref_val);true),
    (nonvar(Stock_Quant_val)->new_value(Material_frame,stock_quantity,Stock_Quant_val);true),
    (nonvar(Product_list_val)->new_value(Material_frame,product_list,Product_list_val);true).

delete_material_F(Material_frame):-
    delete_frame(Material_frame).

add_product_material_F(Material_frame,Product):-
    add_value(Material_frame,product_list,Product).

rmv_product_material_F(Material_frame,Product):-
    remove_value(Material_frame,product_list,Product).

/*--------------------------------------------------*/
/*---------------------DEMONS-----------------------*/
/*--------------------------------------------------*/

/*---------------------FABRICO----------------------*/

fabrico_D(Product,_,[Amount],_):-
    get_value(Product,material_list,Material_list),
    validate_materials_list(Amount,Material_list,0),
    process_materials_list(Amount,Material_list),
    !.

validate_materials_list(_,[],0):-
    write('Product not registered properly'),nl,!,fail.
validate_materials_list(_,[],1).
validate_materials_list(Amount,[[Material,Quant]|Rest],_):-
    get_value(Material,stock_quantity,Stock_quantity),
    Stock_quantity >= Quant*Amount,
    validate_materials_list(Amount,Rest,1),!.
validate_materials_list(_,_,_):-
    write('Not enough material in stock'),nl,
    get_time(Time),
    stamp_date_time(Time, Stamp,local),
    call_method_2(alarm,genmsg,"Not enough material in stock",Stamp),
    !,fail.

process_materials_list(_,[]).
process_materials_list(Amount,[[Material,Quant]|Rest]):-
    get_value(Material,stock_quantity,Stock_quantity),
    New_Stock_quantity is Stock_quantity - Quant*Amount,
    new_value(Material,stock_quantity,New_Stock_quantity),
    process_materials_list(Amount,Rest),!.

/*--------------------ENCOMENDA---------------------*/

encomenda_D(Product,_,[Amount],_):-
    get_value(Product,stock_quantity,Stock_quantity),
    process_order_stock(Product,Stock_quantity,Amount),
    get_value(Product,numb_requests,Numb_requests),
    New_Numb_requests is Numb_requests + 1,
    new_value(Product,numb_requests,New_Numb_requests),
    !.

process_order_stock(_,Stock_quantity,Amount):-
    (Stock_quantity >= Amount),
    !.
process_order_stock(Product,Stock_quantity,Amount):-
    (Stock_quantity < Amount),
    Rest is Amount - Stock_quantity,!,
    call_method_1(Product,fabrico,Rest).

/*--------------------MIN_STOCK---------------------*/

min_stock_Demon(Product,_,Stock,_):-
    get_value(Product,min_stock,Min_stock),
    Min_stock > Stock,
    write('Insufficient stock to meet minimum requirements'),nl,
    Add_stock is 2*Min_stock,
    call_method_1(Product,fabrico,(Add_stock)).


/*--------------TOTAL_PRODUCTS_STOCK----------------*/

total_products_stock_Demon(Product,_,New_stock,New_stock):-
    call_method(factory,read_factory_desc,[_,_,_,Total_stock_val,_]),
    get_value(Product,stock_quantity,Old_stock),
    Diff is New_stock - Old_stock,
    New_total_stock_val is Total_stock_val + Diff,
    call_method(factory,set_factory_desc,[_,_,_,New_total_stock_val]).

/*--------------------------------------------------*/
/*----------------------TEST------------------------*/
/*--------------------------------------------------*/

def_test:-
    call_method(factory,set_factory_desc,['Test Factory','Lisboa',10000,_]),

    call_method(product,create_prod,[product1]),
    call_method(product1,set_prod_desc,[product1,123,_,_,_,24,10]),
    call_method(product1,set_prod_desc,[_,_,_,_,[[material1,10],[material2,10]],_,_]),

    call_method(product,create_prod,[product2]),
    call_method(product2,set_prod_desc,[product2,123,_,_,_,26,10]),
    call_method(product2,set_prod_desc,[_,_,_,_,[[material1,10],[material3,10]],_,_]),
    
    call_method(material,create_material,[material1]),
    call_method(material1,set_material_desc,[material1,123,1500,_]),
    call_method(material1,add_product_material,[product1]),
    call_method(material1,add_product_material,[product2]),

    call_method(material,create_material,[material2]),
    call_method(material2,set_material_desc,[material2,123,1200,_]),
    call_method(material2,add_product_material,[product1]),

    call_method(material,create_material,[material3]),
    call_method(material3,set_material_desc,[material3,123,210,_]),
    call_method(material3,add_product_material,[product2]),

    call_method(material,create_material,[material4]),
    call_method(material4,set_material_desc,[material4,123,600,_]),
    
    call_method_1(product1,fabrico,15),
    call_method_1(product2,fabrico,12),

    get_value(product1,stock_log_list,[[date(Y1, M1, D1),V1]]),
    NM1 is M1 - 2,
    new_value(product1,stock_log_list,[[date(Y1, NM1, D1),V1]]),

    get_value(product2,stock_log_list,[[date(Y2, M2, D2),V2]]),
    NM2 is M2 - 1,
    new_value(product2,stock_log_list,[[date(Y2, NM2, D2),V2]]).

/*--------------------------------------------------*/
/*--------------------------------------------------*/
/*--------------------------------------------------*/

list_product_materials:-
    write('Enter product name: '),
    single_read_string(Product_name),
    (frame_exists(Product_name)->true;(write('Product not resgistered'),nl,fail)),
    get_value(Product_name,material_list,Material_List),
    format('Materials for ~w:~n',[Product_name]),
    forall((member([Material,Stock],Material_List)),
        format('~w: ~w~n',[Material,Stock])
    ).





get_prod_stock_list([],Final_list,Final_list).
get_prod_stock_list([Product|RestProd],List,Final_List):-
    call_method(Product,read_prod_desc,[_,_,Stock_Quant,Stock_List,_,_,_,_]),
    ((Stock_Quant > 0) -> (
        get_stock_list_from_product(Product,Stock_List,[],Final_Stock_List),
        conc(Final_Stock_List,List,New_Final_Stock_List),
        get_prod_stock_list(RestProd,New_Final_Stock_List,Final_List) 
    );
    get_prod_stock_list(RestProd,List,Final_List)).

get_stock_list_from_product(_,[],Final,Final).
get_stock_list_from_product(Product,[Stock|Rest],Current_List,Final_Stock_List):-
    conc([Product],Stock,New_Stock),
    get_stock_list_from_product(Product,Rest,[New_Stock|Current_List],Final_Stock_List).

filter_date_cres(List,Sorted):-
    sort(2,@=<,List,Sorted).

filter_date_decres(List,Sorted):-
    sort(2,@>=,List,Sorted).

list_product_by_order:-
    call_method(factory,read_factory_desc,[_,_,_,_,Products]),
    get_prod_stock_list(Products,[],List),
    format('Order by:~n 1:Crescent Order~n 2:Decrescent Order~n:'),
    single_read_numb(Option),
    (filter_option(Option,List,OrdList)) -> (
        forall((member(SubList,OrdList)),
            (
                [Product, date(Year,Month,Day),Amount] = SubList,
                format('Product ~w:~n  ~w-~w-~w ~w ~n',[Product,Year,Month,Day,Amount])
            )
        )
    ); fail,!.
    
filter_option('r',OrdList,OrdList).
filter_option(_,[],_):-
    write('No Stock in Products'),
    nl,
    fail,
    !.
filter_option(1,List,FinalList):-
    filter_date_cres(List,OrdList),
    filter_option('r',OrdList,FinalList),
    !.
filter_option(2,List,FinalList):-
    filter_date_decres(List,OrdList),
    filter_option('r',OrdList,FinalList),
    !.
filter_option(_,_,_):-
    write('Invalid Option'),
    nl,
    fail,
    !.




list_alarms:-
    call_method(alarm,read_alarm_desc,[_,_,Count]),
    get_alarms(Count,[],Alarm_List),
    forall(member(Alarm,Alarm_List),(
        [Event, date(Year,Month,Day,Hour,Minute,_,_,_,_)] = Alarm,
        format('~w - (~w-~w-~w ~w:~w)~n',[Event,Year,Month,Day,Hour,Minute])
        )
    ).
get_alarms(0,[],[]):-
    write('There is no alarms'),nl,
    !.
get_alarms(0,FL,FL).
get_alarms(Count,List,Final_List):-
    concat(alarm,Count,AlarmName),
    call_method(AlarmName,read_alarm_desc,[Event,Time,_]),
    NewCount is Count-1,
    get_alarms(NewCount,[[Event,Time]|List],Final_List),
    !.

/*--------------------------------------------------*/
/*------------ADD MATERIALS TO PRODUCT--------------*/
/*--------------------------------------------------*/

read_set_prods_material(Product,Material_list):-
    write('Enter material (Enter stop to finish): '),
    single_read_string(Material),
    process_set_prods_material(Product,Material_list,Material),!.

process_set_prods_material(Product,Material_list,stop):-
    call_method(Product,set_prod_desc,[_,_,_,_,Material_list,_,_]),!.
process_set_prods_material(Product,Material_list,Material):-
    dif(Material, stop),
    (if_material_exists(Material)->true;fail),
    (if_material_exists_in_list(Material,Material_list)->(write('Material already in list'),nl,fail);true),
    call_method(Material,add_product_material,[Product]),
    write('Enter necessary material amount: '),
    single_read_numb(Amount),
    conc([Material],[Amount],Material_tuple),
    conc(Material_list,[Material_tuple],Material_list1),
    read_set_prods_material(Product,Material_list1),!.
process_set_prods_material(Product,Material_list,_):-
    read_set_prods_material(Product,Material_list).

add_materials_to_list:-
    write('Enter product name: '),
    single_read_string(Product),
    (frame_exists(Product)->true;(write('Product not resgistered'),nl,press_any_key(_),fail)),
    call_method(Product,read_prod_desc,[_,_,_,_,Material_list,_,_,_]),
    read_set_prods_material(Product,Material_list).

/*--------------------------------------------------*/
/*-----------RMV MATERIALS FROM PRODUCT-------------*/
/*--------------------------------------------------*/

read_rmv_prods_material(Product,Material_list):-
    write('Enter material (Enter stop to finish): '),
    single_read_string(Material),
    process_rmv_prods_material(Product,Material_list,Material),!.

process_rmv_prods_material(Product,Material_list,stop):-
    call_method(Product,set_prod_desc,[_,_,_,_,Material_list,_,_]),!.
process_rmv_prods_material(Product,Material_list,Material):-
    dif(Material, stop),
    (if_material_exists(Material)->true;fail),
    (if_material_exists_in_list(Material,Material_list)->true;(write('Material not in list'),nl,fail)),
    call_method(Material,rmv_product_material,[Product]),
    delete(Material_list,[Material,_],Material_list1),
    read_rmv_prods_material(Product,Material_list1),!.
process_rmv_prods_material(Product,Material_list,_):-
    read_rmv_prods_material(Product,Material_list).

rmv_materials_from_list:-
    write('Enter product name: '),
    single_read_string(Product),
    (frame_exists(Product)->true;(write('Product not resgistered'),nl,press_any_key(_),fail)),
    call_method(Product,read_prod_desc,[_,_,_,_,Material_list,_,_,_]),
    read_rmv_prods_material(Product,Material_list).

/*--------------------------------------------------*/
/*------------------PRODUCT CRUD--------------------*/
/*--------------------------------------------------*/

create_product:-
    write('Enter product name: '),
    single_read_string(Product_name),
    fail_if_product_exists(Product_name),
    write('Enter product reference: '),
    single_read_string(Product_ref),
    call_method(product,create_prod,[Product_name]),
    call_method(Product_name,set_prod_desc,[Product_name,Product_ref,_,_,_,_,_]),
    write('Enter product minimum stock value: '),
    single_read_numb(Min_stock_val),
    call_method(Product_name,set_prod_desc,[_,_,_,_,_,_,Min_stock_val]),
    write('Enter product price (press enter to skip): '),
    (single_read_numb(Price)->(call_method(Product_name,set_prod_desc,[_,_,_,_,_,Price,_]));true).

read_product_desc:-
    write('Enter product name: '),
    single_read_string(Product_name),
    (frame_exists(Product_name)->true;(write('Product not resgistered'),nl,fail)),
    call_method(Product_name,read_prod_desc,[Name,Ref,Stock_Quant,_,_,Price,Min_stock_val,_]),
    format('Name: ~w ~nReference: ~w ~nStock: ~w ~nPrice: ~w ~nMinimum stock: ~w ~n',[Name,Ref,Stock_Quant,Price,Min_stock_val]).

alter_product_desc:-
    write('Enter product name: '),
    single_read_string(Product_name),
    (frame_exists(Product_name)->true;(write('Product not resgistered'),nl,press_any_key(_),fail)),
    write('Enter product stock quantity (press enter to skip): '),
    (single_read_numb(Stock_Quant)->(call_method(Product_name,set_prod_desc,[_,_,Stock_Quant,_,_,_,_]));true),
    write('Enter product price (press enter to skip): '),
    (single_read_numb(Price)->(call_method(Product_name,set_prod_desc,[_,_,_,_,_,Price,_]));true).

rmv_product_from_material_list(_,[]).
rmv_product_from_material_list(Product_name,[[Material,_]|Rest]):-
    call_method(Material,rmv_product_material,[Product_name]),
    rmv_product_from_material_list(Product_name,Rest).

rmv_product:-
    write('Enter product name: '),
    single_read_string(Product_name),
    (frame_exists(Product_name)->true;(write('Product not resgistered'),nl,press_any_key(_),fail)),
    call_method(Product_name,read_prod_desc,[_,_,_,_,Material_list,_,_,_]),
    rmv_product_from_material_list(Product_name,Material_list),
    call_method_0(Product_name,delete_prod),!.

/*--------------------------------------------------*/
/*------------------MATERIAL CRUD-------------------*/
/*--------------------------------------------------*/

create_material:-
    write('Enter material name: '),
    single_read_string(Material_name),
    fail_if_material_exists(Material_name),
    write('Enter material reference: '),
    single_read_string(Material_ref),
    call_method(material,create_material,[Material_name]),
    call_method(Material_name,set_material_desc,[Material_name,Material_ref,_,_]).

read_material_desc:-
    write('Enter material name: '),
    single_read_string(Material_name),
    (frame_exists(Material_name)->true;(write('Material not resgistered'),nl,fail)),
    call_method(Material_name,read_material_desc,[Name,Ref,Stock_Quant,_]),
    format('Name: ~w ~nReference: ~w ~nStock: ~w ~n',[Name,Ref,Stock_Quant]).

alter_material_desc:-
    write('Enter material name: '),
    single_read_string(Material_name),
    (frame_exists(Material_name)->true;(write('Material not resgistered'),nl,press_any_key(_),fail)),
    write('Enter material stock quantity (press enter to skip): '),
    (single_read_numb(Stock_Quant)->(call_method(Material_name,set_material_desc,[_,_,Stock_Quant,_]));true).

rmv_material_from_product(_,[]).
rmv_material_from_product(Material_name,[Product|Rest]):-
    call_method(Product,read_prod_desc,[_,_,_,_,Material_list,_,_,_]),
    delete(Material_list,[Material_name,_],Material_list1),
    call_method(Product,set_prod_desc,[_,_,_,_,Material_list1,_,_]),
    rmv_material_from_product(Material_name,Rest).

rmv_material:-
    write('Enter material name: '),
    single_read_string(Material_name),
    (frame_exists(Material_name)->true;(write('Material not resgistered'),nl,press_any_key(_),fail)),
    call_method(Material_name,read_material_desc,[_,_,_,Product_list]),
    rmv_material_from_product(Material_name,Product_list),
    call_method_0(Material_name,delete_material),!.

/*--------------------------------------------------*/
/*------------------FACTORY INFO--------------------*/
/*--------------------------------------------------*/

get_prod_requests_list([],Final_List,Final_List).
get_prod_requests_list([Product|Rest],Current_list,Final_List):-
    call_method(Product,read_prod_desc,[_,_,_,_,_,_,_,Numb_requests_val]),
    conc(Current_list,[[Product,Numb_requests_val]],Current_list1),
    get_prod_requests_list(Rest,Current_list1,Final_List),!.

read_factory_info:-
    call_method(factory,read_factory_desc,[Name_val,City_val,Max_capacity_val,Total_Stock_val,Product_list]),
    get_prod_requests_list(Product_list,[],Prod_requests_list),
    sort(2,@>=,Prod_requests_list,Sorted),
    member([Popular_product,_],Sorted),
    format('Name: ~w ~nCity: ~w ~nStorage capacity: ~w ~nStock: ~w ~nMost popular product: ~w ~n',[Name_val,City_val,Max_capacity_val,Total_Stock_val,Popular_product]).

alter_factory_info:-
    write('Enter new factory name (press enter to skip): '),
    (single_read_string(Name_val)->(call_method(factory,set_factory_desc,[Name_val,_,_,_]));true),
    write('Enter new factory city (press enter to skip): '),
    (single_read_string(City_val)->(call_method(factory,set_factory_desc,[_,City_val,_,_]));true),
    write('Enter new factory maximum capacity (press enter to skip): '),
    (single_read_numb(Max_capacity_val)->(call_method(factory,set_factory_desc,[_,_,Max_capacity_val,_]));true).

print_all_products:-
    call_method(factory,read_factory_desc,[_,_,_,_,Product_list]),
    write('Lista de produtos: '),nl,nl,
    forall((member(Product,Product_list)),
        (
            format(' -> ~w~n',[Product])
        )
    ).

/*--------------------------------------------------*/
/*-------------------ENCOMENDAR---------------------*/
/*--------------------------------------------------*/

encomendar:-
    write('Enter product name: '),
    single_read_string(Product_name),
    (frame_exists(Product_name)->true;(write('Product not resgistered'),nl,fail)),
    write('Enter amount: '),
    single_read_numb(Amount),
    call_method_1(Product_name,encomenda,Amount).
encomendar.

/*--------------------------------------------------*/
/*--------------------FABRICAR----------------------*/
/*--------------------------------------------------*/

fabricar:-
    write('Enter product name: '),
    single_read_string(Product_name),
    (frame_exists(Product_name)->true;(write('Product not resgistered'),nl,fail)),
    write('Enter amount: '),
    single_read_numb(Amount),
    call_method_1(Product_name,fabrico,Amount).
fabricar.

/*--------------------------------------------------*/
/*----------------------MENU------------------------*/
/*--------------------------------------------------*/

menu :- 
    menu(_).

menu(Op) :- 
    nl,
    write('------------------------------'),nl,
    write('Gestao da base de conhecimento'),nl, 
    write('------------------------------'),nl,
    nl,
    write('1 -> Visualizar informacoes da fabrica'),nl,
    write('2 -> Alterar informacoes da fabrica'),nl,
    write('3 -> Encomendar produto'),nl,
    write('4 -> Fabricar produto'),nl,
    write('5 -> Gestao de produtos'),nl,
    write('6 -> Gestao de pecas'),nl,
    write('7 -> Listagem ordenada'),nl,
    write('8 -> Listagem de alertas'),nl,
    write('9 -> Exit'), nl,
    single_read_option_1(Op),
    exec(Op),
    menu(_),
    !.
menu(_).

product_menu(Op):-
    nl,
    write('-----------------'),nl,
    write('Gestao de produto'),nl, 
    write('-----------------'),nl,
    nl,
    write('1 -> Visualizar Produtos'),nl,
    write('2 -> Criar novo produto'),nl,
    write('3 -> Visualizar descricao de produto'),nl,
    write('4 -> Visualizar pecas de produto'),nl,
    write('5 -> Alterar descricao de produto'),nl,
    write('6 -> Adicionar material a produto'),nl,
    write('7 -> Remover material de produto'),nl,
    write('8 -> Eliminar produto existente'),nl,
    write('9 -> Exit'), nl,
    single_read_option_2(Op1),
    Op is Op1 + 10,
    exec(Op),
    product_menu(_),
    !.
product_menu(_).

material_menu(Op):-
    nl,
    write('------------------'),nl,
    write('Gestao de material'),nl, 
    write('------------------'),nl,
    nl,
    write('1 -> Criar novo material'),nl,
    write('2 -> Visualizar descricao de material'),nl,
    write('3 -> Alterar stock de material'),nl,
    write('4 -> Eliminar material existente'),nl,
    write('5 -> Exit'), nl,
    single_read_option_3(Op1),
    Op is Op1 + 20,
    exec(Op),
    material_menu(_),
    !.
material_menu(_).

exec(1):- read_factory_info,press_any_key(_).
exec(2):- alter_factory_info.
exec(3):- encomendar,press_any_key(_).
exec(4):- fabricar,press_any_key(_).
exec(5):- product_menu(_).
exec(6):- material_menu(_).
exec(7):- list_product_by_order,press_any_key(_).
exec(8):- list_alarms,press_any_key(_).
exec(9):- !,fail.

exec(11):- print_all_products,press_any_key(_).
exec(12):- create_product.
exec(13):- read_product_desc,press_any_key(_).
exec(14):- list_product_materials,press_any_key(_).
exec(15):- alter_product_desc.
exec(16):- add_materials_to_list.
exec(17):- rmv_materials_from_list.
exec(18):- rmv_product.
exec(19):- fail.

exec(21):- create_material.
exec(22):- read_material_desc,press_any_key(_).
exec(23):- alter_material_desc.
exec(24):- rmv_material.
exec(25):- fail.