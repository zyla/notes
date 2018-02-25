Example: tables `Foo`, `Bar`, Foo has-many Bar

### Read

```
type FooFields = Project '["id", "name"] Foo
type BarFields = Project '["id", "name"] Foo
read :: FooId -> Payload '[Single FooFields, Many BarFields]
read fooId = do
  foo <- findFoo fooId
  bars <- findFooBars [get#id foo]
  pure $ mkPayload $
        #foo  =: (project foo <+> #bar_ids =: map (get #id) bars)
    <+> #bars =: map project bars
```

### ReadMany

```
type FooFields = Project '["id", "name"] Foo
type BarFields = Project '["id", "name"] Foo
readMany :: [FooId] -> Payload '[Many FooFields, Many BarFields]
readMany fooIds = do
  foos <- findFoos fooIds
  foos' <- forM foos $ \foo -> do
    barIds <- findFooBarIds (get #id foo)
    pure (foo <+> #bar_ids =: barIds)
  bars <- findBars $ concatMap (get #bar_ids) foos'
  pure $ mkPayload $
        #foos  =: map project foos'
    <+> #bars =: map project bars
```

### Update

```
type FooUpdate = Project '["name"] Foo
update :: FooId -> Payload '[FooUpdate] -> IO ()
update fooId update = do
  updateColumns fooId update

applyUpdate :: Subset update (Columns table) => Key table -> Record update -> IO ()
```

### Create

```
type FooCreate = Project '["name"] Foo
create :: Payload '[FooCreate] -> IO ()
create fooId input = do
  now <- getCurrentTime
  extra <- rtraverse $
       #created_at =: now
   <+> #updated_at =: now

  insertRow fooTable (input <+> extra)
```

###

```
data Update' a = NoUpdate | SetValue a
type Update (Record '["foo" ::: String, "bar" ::: Int]) = Record '["foo" :: Update' String, "bar" ::: Update' Int]

data Serializer m entity a = Serializer
  { read :: entity -> m a
  , update :: a -> Update entity -> m (Update entity) }

fieldSerializer field = Serializer
  { read = get field
  , update = \newValue -> set field (SetValue newValue)
  }
```

How to combine Insert serializers? (to ensure that all mandatory columns are
covered)

```
data Serializer m from to

pair :: Serializer m a1 b1 -> Serializer m a2 b2 -> Serializer m (a1, a2) (b1, b2)
pairOpt :: Serializer m a1 b1 -> Serializer m () b2 -> Serializer m a1 (b1, b2)
```

This looks like product profunctors
