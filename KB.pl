:- dynamic frame_/1.

frame_(factory).
frame_(product).
frame_(material).
frame_(alarm).
frame_(product1).
frame_(product2).
frame_(material1).
frame_(material2).
frame_(material3).
frame_(material4).

:- dynamic factory/1.

factory(frame_).

:- dynamic factory/3.

factory(slot_, name, data_or_method).
factory(slot_, city, data_or_method).
factory(slot_, max_capacity, data_or_method).
factory(slot_, total_products_stock, data_or_method).
factory(slot_, product_list, data_or_method).
factory(slot_, set_factory_desc, data_or_method).
factory(value_, set_factory_desc, set_factory_desc_F).
factory(slot_, add_prod_to_list, data_or_method).
factory(value_, add_prod_to_list, add_prod_to_list_F).
factory(slot_, delete_prod_from_list, data_or_method).
factory(value_, delete_prod_from_list, delete_prod_from_list_F).
factory(slot_, read_factory_desc, data_or_method).
factory(value_, read_factory_desc, read_factory_desc_F).
factory(value_, name, 'Test Factory').
factory(value_, city, 'Lisboa').
factory(value_, max_capacity, 10000).
factory(value_, product_list, product1).
factory(value_, product_list, product2).
factory(value_, total_products_stock, 27).

:- dynamic product/1.

product(frame_).

:- dynamic product/3.

product(slot_, name, data_or_method).
product(slot_, reference, data_or_method).
product(slot_, stock_quantity, data_or_method).
product(value_, stock_quantity, 0).
product(slot_, stock_log_list, data_or_method).
product(value_, stock_log_list, []).
product(slot_, material_list, data_or_method).
product(value_, material_list, []).
product(slot_, price, data_or_method).
product(slot_, min_stock, data_or_method).
product(slot_, numb_requests, data_or_method).
product(value_, numb_requests, 0).
product(slot_, create_prod, data_or_method).
product(value_, create_prod, create_prod_F).
product(slot_, read_prod_desc, data_or_method).
product(value_, read_prod_desc, read_prod_desc_F).
product(slot_, set_prod_desc, data_or_method).
product(value_, set_prod_desc, set_prod_desc_F).
product(slot_, delete_prod, data_or_method).
product(value_, delete_prod, delete_prod_F).
product(slot_, encomenda, data_or_method).
product(value_, encomenda, encomenda_F).
product(slot_, fabrico, data_or_method).
product(value_, fabrico, fabrico_F).

:- dynamic material/1.

material(frame_).

:- dynamic material/3.

material(slot_, name, data_or_method).
material(slot_, reference, data_or_method).
material(slot_, stock_quantity, data_or_method).
material(slot_, product_list, data_or_method).
material(slot_, create_material, data_or_method).
material(value_, create_material, create_material_F).
material(slot_, read_material_desc, data_or_method).
material(value_, read_material_desc, read_material_desc_F).
material(slot_, set_material_desc, data_or_method).
material(value_, set_material_desc, set_material_desc_F).
material(slot_, delete_material, data_or_method).
material(value_, delete_material, delete_material_F).
material(slot_, add_product_material, data_or_method).
material(value_, add_product_material, add_product_material_F).
material(slot_, rmv_product_material, data_or_method).
material(value_, rmv_product_material, rmv_product_material_F).

:- dynamic alarm/1.

alarm(frame_).

:- dynamic alarm/3.

alarm(slot_, event, data_or_method).
alarm(slot_, time_stamp, data_or_method).
alarm(slot_, count, data_or_method).
alarm(value_, count, 0).
alarm(slot_, genmsg, data_or_method).
alarm(value_, genmsg, genmsg_F).
alarm(slot_, read_alarm_desc, data_or_method).
alarm(value_, read_alarm_desc, read_alarm_desc_F).

:- dynamic product1/1.

product1(frame_).

:- dynamic product1/3.

product1(slot_, is_a, relation).
product1(value_, is_a, product).
product1(value_, name, product1).
product1(value_, reference, 123).
product1(value_, price, 24).
product1(value_, min_stock, 10).
product1(value_, material_list, [[material1, 10], [material2, 10]]).
product1(value_, stock_quantity, 15).
product1(value_, stock_log_list, [[date(2021, 4, 21), 15]]).

:- dynamic product2/1.

product2(frame_).

:- dynamic product2/3.

product2(slot_, is_a, relation).
product2(value_, is_a, product).
product2(value_, name, product2).
product2(value_, reference, 123).
product2(value_, price, 26).
product2(value_, min_stock, 10).
product2(value_, material_list, [[material1, 10], [material3, 10]]).
product2(value_, stock_quantity, 12).
product2(value_, stock_log_list, [[date(2021, 5, 21), 12]]).

:- dynamic material1/1.

material1(frame_).

:- dynamic material1/3.

material1(slot_, is_a, relation).
material1(value_, is_a, material).
material1(value_, name, material1).
material1(value_, reference, 123).
material1(value_, product_list, product1).
material1(value_, product_list, product2).
material1(value_, stock_quantity, 1230).

:- dynamic material2/1.

material2(frame_).

:- dynamic material2/3.

material2(slot_, is_a, relation).
material2(value_, is_a, material).
material2(value_, name, material2).
material2(value_, reference, 123).
material2(value_, product_list, product1).
material2(value_, stock_quantity, 1050).

:- dynamic material3/1.

material3(frame_).

:- dynamic material3/3.

material3(slot_, is_a, relation).
material3(value_, is_a, material).
material3(value_, name, material3).
material3(value_, reference, 123).
material3(value_, product_list, product2).
material3(value_, stock_quantity, 90).

:- dynamic material4/1.

material4(frame_).

:- dynamic material4/3.

material4(slot_, is_a, relation).
material4(value_, is_a, material).
material4(value_, name, material4).
material4(value_, reference, 123).
material4(value_, stock_quantity, 600).

:- dynamic relation_/1.

relation_(is_a).

:- dynamic is_a/4.

is_a(relation_, transitive, all, nil).

:- dynamic slot_/2.

slot_(factory, name).
slot_(factory, city).
slot_(factory, max_capacity).
slot_(factory, total_products_stock).
slot_(factory, product_list).
slot_(factory, set_factory_desc).
slot_(factory, add_prod_to_list).
slot_(factory, delete_prod_from_list).
slot_(factory, read_factory_desc).
slot_(product, name).
slot_(product, reference).
slot_(product, stock_quantity).
slot_(product, stock_log_list).
slot_(product, material_list).
slot_(product, price).
slot_(product, min_stock).
slot_(product, numb_requests).
slot_(product, create_prod).
slot_(product, read_prod_desc).
slot_(product, set_prod_desc).
slot_(product, delete_prod).
slot_(product, encomenda).
slot_(product, fabrico).
slot_(material, name).
slot_(material, reference).
slot_(material, stock_quantity).
slot_(material, product_list).
slot_(material, create_material).
slot_(material, read_material_desc).
slot_(material, set_material_desc).
slot_(material, delete_material).
slot_(material, add_product_material).
slot_(material, rmv_product_material).
slot_(alarm, event).
slot_(alarm, time_stamp).
slot_(alarm, count).
slot_(alarm, genmsg).
slot_(alarm, read_alarm_desc).
slot_(product1, is_a).
slot_(product2, is_a).
slot_(material1, is_a).
slot_(material2, is_a).
slot_(material3, is_a).
slot_(material4, is_a).

:- dynamic demon_/2.

demon_(product, stock_quantity).
demon_(product, stock_quantity).
demon_(product, encomenda).
demon_(product, fabrico).

:- dynamic stock_quantity/6.

stock_quantity(demon_, product, min_stock_Demon, if_write, after, side_effect).
stock_quantity(demon_, product, total_products_stock_Demon, if_write, before, side_effect).

:- dynamic encomenda/6.

encomenda(demon_, product, encomenda_D, if_execute, before, side_effect).

:- dynamic fabrico/6.

fabrico(demon_, product, fabrico_D, if_execute, before, side_effect).

