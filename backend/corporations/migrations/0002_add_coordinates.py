from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('corporations', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='corporation',
            name='latitude',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='corporation',
            name='longitude',
            field=models.FloatField(blank=True, null=True),
        ),
    ]
