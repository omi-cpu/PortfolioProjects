# importing libraries

import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

plt.style.use('ggplot')
from matplotlib.pyplot import figure

# %matplotlib inline
# matplotlib.rcParams['figure.figsize'] = (12,8) #adjusts the configuration of the plot that'll be created

# read in the data
df = pd.read_csv('/Users/user/Downloads/movies.csv')
df.head()

# checking for missing data
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print ('{} - {}%'.format(col,pct_missing))


# data types for the columns
print(df.dtypes)

# changing the data types of the columns

df['budget'] = df['budget'].fillna(0) # converts nulls to 0
df['budget'] = df['budget'].astype('int64')

df['gross'] = df['gross'].fillna(0) # converts nulls to 0
df['gross'] = df['gross'].astype('int64')

# the year column shows the year each movie was released but it doesn't tally with the released1 column. I'll create a new column now that takes the released_year from the released column
df['correct_year'] = df['released1'].astype('str').str[-4:]
# print(df.correct_year)


# sorting by highest grossing movie
o = df.sort_values(by=['gross'], inplace=False, ascending=False)
w = pd.set_option('display.max_rows', None) # to print out all the rows 
# print(w)


# drop any duplicates
df['company'].drop_duplicates().sort_values(ascending=False) # select distinct
df['company'].sort_values(ascending=False)


# budget will have a high correlation to the gross amount brought in

# scatter plot of budget vs gross
plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget vs Gross Earnings')
plt.ylabel('Gross Earnings')
plt.xlabel('Budget')
# plt.show()

# budget vs gross using seaborn
sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color": "red"}, line_kws={"color": "blue"})
# plt.show()

# looking at correlation
df.corr() # works only with numerical fields # pearson, kendall & spearman correlation methods
# df.corr(method='kendall')

correlation_matrix = df.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matric for Numeric Features')
plt.ylabel('Gross Earnings')
plt.xlabel('Budget')
#plt.show()

df_numerized = df
# df_numerized.head()
for col_name in df_numerized.columns:
    if (df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes # generates random numbers for the string columns
print(df_numerized)

correlation_matrix = df_numerized.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matric for Numeric Features')
plt.ylabel('Gross Earnings')
plt.xlabel('Budget')
# plt.show()

correlation_mat = df_numerized.corr()
corr_pairs = correlation_mat.unstack() # comapres 
print(corr_pairs)
# OR
sorted_pairs = corr_pairs.sort_values()
print(sorted_pairs)

high_corr = sorted_pairs[(sorted_pairs) > 0.5]
print(high_corr)

# votes and budget have the highest correlation to gross earnings

# company has low correlation