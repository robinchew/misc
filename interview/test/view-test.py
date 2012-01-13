def list_store(request):
    temp =[]
    store_list = ''
    flag = 0
    flg = 0
    code_flg = 0
    gets = {}
    gets_string=''
    form = SearchStoreForm()
    form2 = SearchItemForm()
    dict = {
            'keyword':'store__name__contains',
            'category':'category',
            'line':'id'
            }
    dict2 = {
            'keyword':'name__contains'
            }
    temp_store = None
    temp_store2 = None
    new_stores = None
    new_arrival = None
    corrected_query=''
    if request.method == 'GET':
      gets=request.GET.copy()
      kwargs = {}
      kwargs2 = {}
      form = SearchStoreForm(request.GET)

      for field in request.GET.items():
        if field[0]!='submit':
           if field[1]:
                if dict.has_key(field[0]):
                    kwargs[str(dict[field[0]])] = field[1]
                    if field[0]=='keyword' and field[1]!='':
                      kwargs2[str(dict2[field[0]])] = field[1]
                else:
                    kwargs[str(field[0])]=field[1]
                gets[field[0]]=field[1]
        if kwargs:
            temp_store = Line.objects.filter(store__deleted=False,**kwargs)
            for data in temp_store :
                temp.append(data.store.id)
        if kwargs2 :
            temp_store2 = Store.objects.filter(deleted=False,**kwargs2)
            for data in temp_store2 :
                temp.append(data.id)
        store_list = Store.objects.filter(id__in=temp)
        for store in store_list :
            try:
                addict = Addicted.objects.get(store=store,user=request.user,deleted=False)
            except:
                addict = ''
            if addict :
                store.addicted = True
            else:
                store.addicted = False
        if store_list.count() > 3:
            flg = 1
        else:
            flg = 0
        code_flg = 1

    gets_string=gets.urlencode()
    new_stores = Store.objects.filter(deleted=False).order_by('-id')
    new_arrival = Item.objects.filter(line__store__deleted=False).order_by('-id')
    paginator = Paginator(store_list,5)
    try:
        page = int(request.GET.get('page','1'))
    except ValueError:
        page = 1
    try:
        stores = paginator.page(page)
    except:
        stores = paginator.page(paginator.num_pages)

    return direct_to_template(request,'store/search_base.html',{'stores':stores,'form':form,'form2':form2,'flag':flag,'new_stores':new_stores,'new_arrival':new_arrival,'temp_flg':flg,'code_flg':code_flg,'gets_string':gets_string})
