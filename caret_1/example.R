lesson_info = list(Course = "advdatasci_swirl", Lesson = "caret_1", 
                   Author = "Detian Deng", Type = "Standard", 
                   Organization = "JHU Biostatistics and DSL",
                   Version = "2.4.2")
## In this swirl class, you will learn to use the caret package to create proper data split, and evaluate your predictive model performance. 

## First, let's review the steps of training, choosing, and evaluating a predictive (regression/classification) model.

## 1. Divide you data set into 2 sets: training and testing, with ratio around 70:30.

## 2. Further split training set into K (usually 10) parts, and use K-fold cross-validation to tune parameters or to choose between different models.

## 3. Train the selected model with all data in training set and make prediction on the testing set, then calculate the out-of-sample error metric.

## For regression problem, the error metric is usually Mean Square Error or Mean Absolute Error. For classification problem, the metric can be accuracy, kappa score, a weighted average of sensitivity and specificity or AUC of ROC curve.

## In caret package, the function 'createDataPartition' can be used to create balanced splits of the data. If the y argument to this function is a factor, the random sampling occurs within each class and should preserve the overall class distribution of the data.

## For example, to create a single 80/20% split of the iris data, you can use: createDataPartition(iris$Species, p = .8, list = FALSE, times = 1)

# Now try to creat a variable named trainIndex by the above function.
trainIndex <- createDataPartition(iris$Species, p = .8, list = FALSE, times = 1)

## The list = FALSE avoids returns the data as a list. This function also has an argument, times, that can create multiple splits at once; the data indices are returned in a list of integer vectors. 

# Then use this index variable to create your training set.
irisTrain <- iris[trainIndex, ]

# And your testing set as well
irisTest  <- iris[-trainIndex, ]

## To further create a 10-fold training set, you can use: createFolds(irisTrain$Species, k = 10, list = TRUE, returnTrain = FALSE)

# Now creat a variable named cvIndex by the above function.
cvIndex <- createFolds(irisTrain$Species, k = 10, list = TRUE, returnTrain = FALSE)

## Although you can use the above index to program your own cross-validation, caret package offers a more convinient way to do it.

# Use the following command to create an object to control your model training process: fitControl <- trainControl(method = "cv", number = 10)
fitControl <- trainControl(method = "cv", number = 10, repeats = 1, classProbs = TRUE, summaryFunction = twoClassSummary)

## Note that classProbs = TRUE, summaryFunction = twoClassSummary are specific to classification problems.

# Then you can train your elastic net model using: glmnetFit <- train(Species ~ ., data = irisTrain, method = "glmnet", trControl = fitControl, metric = "ROC")
glmnetFit <- train(Species ~ ., data = irisTrain, method = "glmnet", trControl = fitControl, metric = "ROC")

## Where you use metric = "ROC" to choose what type of error metric you want to use.

# Now take a look at the cross-validation performance
glmnetFit

## It seams you have a perfect fitting regardless of the value of tuning parameters. If there were differences between the model performances, the train function would select the best model in terms of the metric you chose, train the model on the full training data and return it. 

# Therefore, you have already got yout best model in glmnetFit, now you can evaluate its performance on the testing data. First, make the predictions with the predict function and assign it to glmnetPred.
glmnetPred <- predict(glmnetFit, newdata = irisTest)

# Then you can evaluate the classification performance using the 'confusionMatrix' function.
confusionMatrix(glmnetPred, irisTest$Species)

# Now let's try regression. First, remove classProbs = TRUE, summaryFunction = twoClassSummary from the fitControl object.
fitControl <- trainControl(method = "cv", number = 10, repeats = 1)

# Train regression model on one of its covariates: Petal.Width.
glmnetFit <- train(Petal.Width ~ ., data = irisTrain, method = "glmnet", trControl = fitControl)

# Now take a look at the cross-validation performance
glmnetFit

## This time the model performances are different, and the best model based on the default metric RMSE is returned.

# Make predictions on testing data.
glmnetPred <- predict(glmnetFit, newdata = irisTest)

# Calculate the RMSE 
sqrt(mean((glmnetPred - irisTest$Petal.Width)^2))

## The out-of-sample RMSE is very close to the cross-validated RMSE. It suggests that the model is unlikely to be over-fitting.