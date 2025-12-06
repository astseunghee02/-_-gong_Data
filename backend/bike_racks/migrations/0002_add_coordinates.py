from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('bike_racks', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='bikerack',
            name='latitude',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='bikerack',
            name='longitude',
            field=models.FloatField(blank=True, null=True),
        ),
    ]
